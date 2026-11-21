#!/bin/bash
# Default-deny outbound firewall for the dev container. Runs as root at every container
# start (postStartCommand in devcontainer.json).
#
# It fails closed: the default policies are set to DROP before anything else, and if
# any later step fails, an exit handler empties the allowed set, so only loopback and DNS
# to the configured resolvers remain open. A failure shows as an error when the container
# starts; the container keeps running, but with no outbound access.
#
# The firewall exists only if this script runs. A container started some other way (for
# example from Docker Desktop's dashboard) has open outbound access: start it from VS
# Code, and run verify-container.sh if in doubt.
#
# Adapted from Anthropic's reference script:
#   https://github.com/anthropics/claude-code/blob/26a5b52bb5d9f53bff6b4804214ec88deab78ce3/.devcontainer/init-firewall.sh
#
# Differences from upstream:
#   - Default-deny policies are applied first, not last, and a failure empties the
#     allowed set, so the script fails closed.
#   - Allowed traffic is HTTPS only (TCP 443), not every port on an allowed address.
#   - Allowed hostnames come from /usr/local/etc/allowed-domains.txt (root-owned, baked
#     into the image) instead of being hard-coded here.
#   - Telemetry hosts (sentry.io, statsig.com) and the npm registry are not allowed by
#     default. Projects add registries through their own CRs.
#   - No outbound SSH, and no blanket access to the Docker bridge network (VS Code
#     reaches the container through docker exec, which doesn't need it).
#   - DNS is allowed only to the resolvers in /etc/resolv.conf, not to any host.
#   - IPv6 is blocked too, so it can't be used to get round the IPv4 rules.
#   - The final check also confirms the Anthropic API is reachable.

set -euo pipefail
IFS=$'\n\t'

ALLOWLIST=/usr/local/etc/allowed-domains.txt
IPV4_RE='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
CIDR4_RE='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$'

# On any exit before setup completes (an error, or an explicit exit 1), remove every
# allowed address, so a half-finished setup leaves nothing reachable.
completed=0
on_exit() {
    if [ "$completed" -ne 1 ]; then
        ipset flush allowed-hosts 2>/dev/null || true
        echo "ERROR: Firewall setup failed. Outbound traffic is blocked apart from DNS." >&2
    fi
}
trap on_exit EXIT

# Resolve a hostname and add its IPv4 addresses to the allowed set
allow_host() {
    local domain=$1 ips ip
    ips=$(dig +noall +answer A "$domain" | awk '$4 == "A" {print $5}')
    if [ -z "$ips" ]; then
        echo "ERROR: Failed to resolve $domain"
        return 1
    fi
    while read -r ip; do
        if [[ ! "$ip" =~ $IPV4_RE ]]; then
            echo "ERROR: Invalid IP from DNS for $domain: $ip"
            return 1
        fi
        ipset add -exist allowed-hosts "$ip"
    done <<< "$ips"
    echo "Allowed $domain"
}

# 1. Block everything first. Then keep Docker's internal DNS forwarding rules, which the
#    flush below would otherwise remove.
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
DOCKER_DNS_RULES=$(iptables-save -t nat | grep "127\.0\.0\.11" || true)
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-hosts 2>/dev/null || true

if [ -n "$DOCKER_DNS_RULES" ]; then
    echo "Restoring Docker DNS rules..."
    iptables -t nat -N DOCKER_OUTPUT 2>/dev/null || true
    iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
    echo "$DOCKER_DNS_RULES" | xargs -L 1 iptables -t nat
fi

# 2. IPv6: loopback only. If ip6tables can't be configured, carry on only when the
#    container has no global IPv6 address (so there is no IPv6 route out).
if ip6tables -P INPUT DROP 2>/dev/null \
    && ip6tables -P FORWARD DROP \
    && ip6tables -P OUTPUT DROP \
    && ip6tables -F \
    && ip6tables -X \
    && ip6tables -A INPUT -i lo -j ACCEPT \
    && ip6tables -A OUTPUT -o lo -j ACCEPT \
    && ip6tables -A OUTPUT -j REJECT; then
    echo "IPv6 blocked"
elif [ -n "$(ip -6 addr show scope global 2>/dev/null)" ]; then
    echo "ERROR: Could not block IPv6, and the container has a global IPv6 address"
    exit 1
else
    echo "IPv6 rules unavailable, but the container has no global IPv6 address"
fi

# 3. What is allowed: loopback, replies to allowed connections, DNS to the configured
#    resolvers, and HTTPS to addresses in the allowed set.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

resolvers=$(awk '$1 == "nameserver" {print $2}' /etc/resolv.conf)
if [ -z "$resolvers" ]; then
    echo "ERROR: No DNS resolvers found in /etc/resolv.conf"
    exit 1
fi
while read -r ns; do
    if [[ ! "$ns" =~ $IPV4_RE ]]; then
        echo "Skipping non-IPv4 resolver $ns (IPv6 is blocked)"
        continue
    fi
    iptables -A OUTPUT -p udp -d "$ns" --dport 53 -j ACCEPT
    iptables -A OUTPUT -p tcp -d "$ns" --dport 53 -j ACCEPT
    echo "Allowed DNS to resolver $ns"
done <<< "$resolvers"

ipset create allowed-hosts hash:net
iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed-hosts dst -j ACCEPT
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

# 4. GitHub: allow the API host first so its published address ranges can be fetched.
allow_host api.github.com
gh_ranges=$(curl -fsS --connect-timeout 10 https://api.github.com/meta)
if ! echo "$gh_ranges" | jq -e '.web and .api and .git' >/dev/null; then
    echo "ERROR: GitHub meta response missing required fields"
    exit 1
fi
# Computed first (not read through a process substitution) so a failure in jq or
# aggregate stops the script instead of silently giving an empty list
gh_cidrs=$(echo "$gh_ranges" | jq -r '(.web + .api + .git)[]' | grep -v ':' | aggregate -q)
if [ -z "$gh_cidrs" ]; then
    echo "ERROR: No IPv4 ranges in GitHub meta response"
    exit 1
fi
while read -r cidr; do
    if [[ ! "$cidr" =~ $CIDR4_RE ]]; then
        echo "ERROR: Invalid CIDR range from GitHub meta: $cidr"
        exit 1
    fi
    ipset add -exist allowed-hosts "$cidr"
done <<< "$gh_cidrs"
echo "Allowed GitHub address ranges"

# 5. Hosts from the allowlist file.
if [ ! -r "$ALLOWLIST" ]; then
    echo "ERROR: Allowlist $ALLOWLIST not found"
    exit 1
fi
domains=$(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$ALLOWLIST" | grep -v '^$' || true)
while read -r domain; do
    if [ -n "$domain" ]; then
        allow_host "$domain"
    fi
done <<< "$domains"

# 6. Check the result: a host that isn't allowed must fail, allowed ones must work.
echo "Verifying firewall rules..."
if curl --connect-timeout 5 -s https://example.com >/dev/null 2>&1; then
    echo "ERROR: Firewall verification failed: able to reach https://example.com"
    exit 1
fi
echo "OK: https://example.com is blocked"
for url in https://api.github.com/zen https://api.anthropic.com; do
    # Any HTTP response (even an error status) proves the connection was allowed
    if ! curl --connect-timeout 5 -s -o /dev/null "$url"; then
        echo "ERROR: Firewall verification failed: unable to reach $url"
        exit 1
    fi
    echo "OK: $url is reachable"
done
completed=1
echo "Firewall configuration complete"
