#!/bin/bash
# Checks that the dev container is contained, for CR-0001 AC2, AC3 and AC5. Run it in a
# VS Code terminal attached to the container (not through "docker exec", which would
# miss the VS Code git sign-in check):
#
#   bash .devcontainer/verify-container.sh
#
# Each check is named after the criterion it verifies. The script changes nothing in the
# project; it uses a throwaway git repository in /tmp for the secret-scan check.
# Exits non-zero if any check fails.
set -uo pipefail

pass=0
fail=0
result() {  # result <check-name> <0|1> <detail>
    if [ "$2" -eq 0 ]; then
        printf 'PASS  %-40s %s\n' "$1" "$3"
        pass=$((pass + 1))
    else
        printf 'FAIL  %-40s %s\n' "$1" "$3"
        fail=$((fail + 1))
    fi
}
reachable() {  # reachable <url>: any HTTP response counts as reachable
    curl -s -o /dev/null --connect-timeout 5 --max-time 10 "$1"
}

echo "== AC2: network"
if reachable https://example.com; then
    result cr0001-ac2-example-com-blocked 1 "https://example.com was reachable"
else
    result cr0001-ac2-example-com-blocked 0 "https://example.com unreachable"
fi
if reachable https://api.github.com/zen; then
    result cr0001-ac2-github-reachable 0 "https://api.github.com reachable"
else
    result cr0001-ac2-github-reachable 1 "https://api.github.com unreachable"
fi
if reachable https://api.anthropic.com; then
    result cr0001-ac2-anthropic-reachable 0 "https://api.anthropic.com reachable"
else
    result cr0001-ac2-anthropic-reachable 1 "https://api.anthropic.com unreachable"
fi
if timeout 5 bash -c '</dev/tcp/github.com/22' 2>/dev/null; then
    result cr0001-ac2-ssh-to-github-blocked 1 "github.com port 22 was reachable"
else
    result cr0001-ac2-ssh-to-github-blocked 0 "github.com port 22 unreachable"
fi
if reachable http://github.com; then
    result cr0001-ac2-http-port-80-blocked 1 "http://github.com (port 80) was reachable"
else
    result cr0001-ac2-http-port-80-blocked 0 "http://github.com (port 80) unreachable"
fi
if curl -6 -s -o /dev/null --connect-timeout 5 https://example.com 2>/dev/null; then
    result cr0001-ac2-ipv6-blocked 1 "IPv6 traffic got out"
else
    result cr0001-ac2-ipv6-blocked 0 "no IPv6 traffic out"
fi

echo "== AC3: host isolation"
# Folders shared from the host appear with one of these file system types
host_mounts=$(awk '$3 ~ /^(virtiofs|fakeowner|grpcfuse|fuse\.grpcfuse|osxfs|9p)$/ {print $2}' /proc/mounts | sort -u)
if [ "$host_mounts" = "/workspace" ]; then
    result cr0001-ac3-only-project-folder-shared 0 "only /workspace is shared from the host"
elif [ -z "$host_mounts" ]; then
    result cr0001-ac3-only-project-folder-shared 1 "no host share recognised; check 'mount' by hand"
else
    result cr0001-ac3-only-project-folder-shared 1 "host shares: $(echo "$host_mounts" | tr '\n' ' ')"
fi
if [ -e /Users ] || [ "$(ls /home)" != "node" ]; then
    result cr0001-ac3-no-host-home 1 "/Users exists or /home holds more than node"
else
    result cr0001-ac3-no-host-home 0 "no host home folders visible"
fi
sockets=$(find /tmp -maxdepth 2 -type s \( -name '*ssh*' -o -name 'vscode-ssh-auth*' \) 2>/dev/null)
if [ -n "${SSH_AUTH_SOCK:-}" ] || [ -n "$sockets" ]; then
    result cr0001-ac3-no-ssh-agent 1 "SSH agent visible: ${SSH_AUTH_SOCK:-} $sockets"
else
    result cr0001-ac3-no-ssh-agent 0 "no SSH agent variable or socket"
fi
helpers=$(git config --get-all credential.helper 2>/dev/null)
if [ -n "$helpers" ] || [ -e "$HOME/.git-credentials" ]; then
    result cr0001-ac3-no-git-credentials 1 "git credential helper or file present: $helpers"
else
    result cr0001-ac3-no-git-credentials 0 "no git credential helper or stored credentials"
fi
askpass=$(env | grep -E '^(GIT_ASKPASS|VSCODE_GIT_ASKPASS_[A-Z_]+)=' | cut -d= -f1 | tr '\n' ' ')
if [ -n "$askpass" ]; then
    result cr0001-ac3-no-vscode-git-signin 1 "VS Code git sign-in passthrough set: $askpass"
else
    result cr0001-ac3-no-vscode-git-signin 0 "no VS Code git sign-in passthrough"
fi

echo "== AC5: secret scan before commit"
hooks=$(git config --global --get core.hooksPath 2>/dev/null)
if [ "$hooks" != "/workspace/.githooks" ]; then
    result cr0001-ac5-precommit-blocks-secret 1 "core.hooksPath is '$hooks', not /workspace/.githooks"
else
    tmp=$(mktemp -d)
    git -C "$tmp" init -q
    git -C "$tmp" config user.name "verify" && git -C "$tmp" config user.email "verify@example.invalid"
    # Control: a clean commit must go through, so a hook that blocks everything can't pass
    echo "nothing secret here" > "$tmp/clean.txt"
    git -C "$tmp" add clean.txt
    if ! git -C "$tmp" commit -q -m "clean" >/dev/null 2>&1; then
        result cr0001-ac5-precommit-blocks-secret 1 "the hook blocked a clean commit, so it isn't working"
    else
        token="ghp_$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36)"
        printf 'token = "%s"\n' "$token" > "$tmp/fake.txt"
        git -C "$tmp" add fake.txt
        if out=$(git -C "$tmp" commit -m "should be blocked" 2>&1); then
            result cr0001-ac5-precommit-blocks-secret 1 "a commit containing a fake token was accepted"
        elif echo "$out" | grep -q "leaks found"; then
            result cr0001-ac5-precommit-blocks-secret 0 "clean commit accepted; fake token blocked by gitleaks"
        else
            result cr0001-ac5-precommit-blocks-secret 1 "commit failed, but not because gitleaks found a leak"
        fi
    fi
    rm -rf "$tmp"
fi

echo "== $pass passed, $fail failed"
[ "$fail" -eq 0 ]
