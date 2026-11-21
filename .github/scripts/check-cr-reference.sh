#!/bin/bash
# CR-0000 AC1: a pull request must say which CR it implements, on a line of the form
# "Implements: CR-NNNN", and that CR must have a file in docs/cr/. Other CR numbers
# mentioned elsewhere in the description (for example a future CR) are ignored.
#
# Reads the PR description from the PR_BODY environment variable, never from the
# command line, so untrusted text can't inject shell commands. Run from the
# repository root; runs in CI as part of the "PR references a CR" job.
set -euo pipefail

ids=$(printf '%s' "${PR_BODY:-}" \
    | grep -Eo 'Implements:[[:space:]`*]*CR-[0-9]{4}' \
    | grep -Eo 'CR-[0-9]{4}' | sort -u || true)

if [ -z "$ids" ]; then
    echo "::error::The PR description must say which CR it implements, on a line like 'Implements: CR-0001'"
    exit 1
fi

for id in $ids; do
    if ! ls docs/cr/"$id"-*.md >/dev/null 2>&1; then
        echo "::error::The PR implements $id, but there is no docs/cr/$id-*.md"
        exit 1
    fi
    echo "Implements $id, found in docs/cr/"
done
