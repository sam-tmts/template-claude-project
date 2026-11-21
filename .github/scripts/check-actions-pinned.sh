#!/bin/bash
# CR-0000 AC4: every third-party GitHub Action is pinned to a full commit SHA, and every
# workflow's token is read-only. Runs in CI (job cr0000-ac4-actions-pinned) and can be
# run locally from the repository root.
set -euo pipefail

fail=0
shopt -s nullglob
files=(.github/workflows/*.yml .github/workflows/*.yaml)
if [ ${#files[@]} -eq 0 ]; then
    echo "No workflow files found"
    exit 1
fi

for f in "${files[@]}"; do
    while IFS= read -r line; do
        # Strip the "uses:" key, any trailing comment and any quotes
        ref=$(echo "$line" | sed -E "s/^[[:space:]-]*uses:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[\"']//g")
        case "$ref" in
            ./*) continue ;;  # actions inside this repository
        esac
        if [[ ! "$ref" =~ ^[^@[:space:]]+@[0-9a-f]{40}$ ]]; then
            echo "::error file=$f::Not pinned to a full commit SHA: $ref"
            fail=1
        fi
    done < <(grep -E '^[[:space:]-]*uses:' "$f" || true)

    if ! grep -Eq '^permissions:' "$f"; then
        echo "::error file=$f::No top-level permissions block"
        fail=1
    fi
    if grep -Eq '^[[:space:]]*(permissions:[[:space:]]*write-all|[a-z-]+:[[:space:]]*write)' "$f"; then
        echo "::error file=$f::Workflow asks for write permission"
        fail=1
    fi
done

if [ "$fail" -eq 0 ]; then
    echo "All actions pinned to full commit SHAs; all workflow tokens read-only"
fi
exit "$fail"
