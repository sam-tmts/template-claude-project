#!/bin/bash
# CR-0001 AC1, check cr0001-ac1-firewall-fails-closed: runs init-firewall.sh with the
# system commands it uses (iptables, ipset, dig, curl, ...) replaced by stubs, and checks
# that a failure part-way through empties the allowed set, while a good run completes.
# Needs no root and no container: run from the repository root with
#
#   bash .devcontainer/tests/test-firewall-fails-closed.sh
#
# M5 in docs/test-plan.md checks the same thing against a real kernel.
set -uo pipefail

script=.devcontainer/init-firewall.sh
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

for cmd in iptables ip6tables iptables-save ipset; do
    printf '#!/bin/sh\necho "%s $*" >> "%s/log"\n' "$cmd" "$work" > "$work/bin/$cmd"
done
# dig resolves every name to a documentation address, except names containing "bad"
printf '#!/bin/sh\ncase "$*" in *bad*) exit 0;; esac\necho "x. 60 IN A 192.0.2.10"\n' > "$work/bin/dig"
cat > "$work/bin/curl" <<'EOF'
#!/bin/sh
case "$*" in
  *api.github.com/meta*) echo '{"web":["192.0.2.0/24"],"api":["198.51.100.0/24"],"git":["203.0.113.0/24"]}' ;;
  *example.com*) exit 7 ;;
esac
exit 0
EOF
printf '#!/bin/sh\ncat\n' > "$work/bin/aggregate"
# shellcheck disable=SC2016  # $1 belongs to the stub, not to this script
printf '#!/bin/sh\n[ "$1" = "-6" ] && exit 0\necho "default via 172.17.0.1 dev eth0"\n' > "$work/bin/ip"
chmod +x "$work/bin/"*
echo "nameserver 127.0.0.11" > "$work/resolv.conf"

run_with_allowlist() {  # run_with_allowlist <allowlist contents>; sets $status
    printf '%s\n' "$1" > "$work/allow"
    rm -f "$work/log"
    sed -e "s#/usr/local/etc/allowed-domains.txt#$work/allow#" \
        -e "s#/etc/resolv.conf#$work/resolv.conf#" "$script" > "$work/fw.sh"
    PATH="$work/bin:$PATH" bash "$work/fw.sh" > "$work/out" 2>&1
    status=$?
}

fail=0
run_with_allowlist "api.anthropic.com"
if [ "$status" -eq 0 ] && ! grep -q "ipset flush" "$work/log"; then
    echo "PASS  good allowlist: setup completes and keeps its allowed set"
else
    echo "FAIL  good allowlist: exit $status"; cat "$work/out"; fail=1
fi

run_with_allowlist "api.anthropic.com
bad.invalid"
if [ "$status" -ne 0 ] && grep -q "ipset flush allowed-hosts" "$work/log"; then
    echo "PASS  cr0001-ac1-firewall-fails-closed: a failure part-way empties the allowed set"
else
    echo "FAIL  cr0001-ac1-firewall-fails-closed: exit $status, allowed set not emptied"
    cat "$work/out"; fail=1
fi

if grep -q "iptables -P OUTPUT DROP" "$work/log"; then
    echo "PASS  default-deny policy applied"
else
    echo "FAIL  default-deny policy not applied"; fail=1
fi

exit "$fail"
