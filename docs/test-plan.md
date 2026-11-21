# Test plan

How this project is tested, and how anyone can check it independently. Each project
fills in the strategy in its first CR and adds manual checks as new acceptance criteria
need them.

> **Template note.** The template has no code, so it has no unit tests. Its checks are
> the CI jobs and the manual checks below. A project replaces the strategy and the
> command, and keeps its own manual checks after the template's.

## Strategy

- **Levels and types:** which levels (unit, integration, end-to-end) and which kinds of
  testing (functional, security, usability, performance) the project uses, and what
  each covers.
- **Layout and tools:** where each level of test lives (for example `tests/unit/`,
  `tests/integration/`, `tests/fixtures/`), the test runner, and any coverage
  expectation.
- **Not tested:** what is deliberately left out, and why.
- **Risks:** where testing effort is concentrated.
- **Environments and test data:** where tests run, and where test data comes from.
  Never real credentials or personal data.
- **Release criteria:** what must be true before a release.

## Running everything

The single command that runs every automated check, locally and in CI:

```sh
<command, set in the project's first CR>
```

For the template itself, the automated checks are the CI jobs in
`.github/workflows/ci.yml`, which run on every pull request and every push to `main`,
the firewall's fail-closed test, which needs no container:

```sh
bash .devcontainer/tests/test-firewall-fails-closed.sh
```

and the container checks, run in a VS Code terminal attached to the dev container:

```sh
bash .devcontainer/verify-container.sh
```

## Manual checks

Checks that can't be automated. Each one names the acceptance criterion it verifies.

| ID | Verifies | Steps | Expected result |
|----|----------|-------|-----------------|
| M1 | CR-0000 AC1 | Open a pull request with an empty description. Then edit the description to `Implements: CR-9999`. Then edit it to `Implements: CR-0000`. | The "PR references a CR" check fails, fails again, then passes. Mentions of other CRs elsewhere in the description don't affect it. |
| M2 | CR-0000 AC2 | Push a commit containing a fake secret to a throwaway branch. If the push is accepted, open a pull request from it. Record which of the two stopped it. | GitHub push protection rejects the push, or the CI secret scan fails and blocks the merge. Close the pull request and delete the branch afterwards (the commit stays reachable through the closed pull request, which is harmless for a fake secret). |
| M3 | CR-0000 AC5 | Try to push a commit directly to `main`. | Rejected: "Changes must be made through a pull request". |
| M4 | CR-0000 AC6 | Create a repository from the template on GitHub. Apply the repository settings in its README (GitHub doesn't copy settings from a template). Open a pull request naming CR-0000, then repeat M1 and M3 in the new repository. | Every template file is present, CI passes, M1 and M3 behave as in this repository, and the README lists the settings to apply and what a project must change first. Delete the repository afterwards. |
| M5 | CR-0001 AC1 | In a copy of the project, add a hostname that doesn't exist (for example `no-such-host.invalid`) to `.devcontainer/allowed-domains.txt`, rebuild the container, and watch it start. Then, in its terminal, try `curl https://api.github.com/zen` and `curl https://api.anthropic.com`. If VS Code won't attach after the error, use `docker exec -it <container> bash` from the host. Delete the copy afterwards. | Firewall setup reports an error, and both `curl` commands fail: nothing gets out. (The automated test `cr0001-ac1-firewall-fails-closed` checks the same logic without a container.) |
| M6 | CR-0001 AC2 | Run `verify-container.sh` in a VS Code terminal attached to the container. On the first build, also record the image digests (`docker image inspect --format '{{index .RepoDigests 0}}' node:22-bookworm ghcr.io/gitleaks/gitleaks:v8.30.1` on the host) and the Claude Code extension version (VS Code's Extensions view), for pinning. | Every `cr0001-ac2-…` check passes. |
| M7 | CR-0001 AC3 | Run `verify-container.sh` in a VS Code terminal attached to the container. | Every `cr0001-ac3-…` check passes. |
| M8 | CR-0001 AC4 | In Claude Code inside the container, explain that this is an owner-authorised test of the permission rules, then ask it to: read a dummy `.env` file with its file tool; run `cat .env`; force-push a branch; run `gh pr merge`; edit a file in `.devcontainer/`. | For the first four, Claude Code attempts the action and it is blocked by a permission rule (the deny message is shown), not just declined by the model. The edit asks for permission first. |
| M9 | CR-0001 AC5 | Run `verify-container.sh` in a VS Code terminal attached to the container. | The `cr0001-ac5-precommit-blocks-secret` check passes (a clean commit goes through and a fake token is blocked by gitleaks). |
| M10 | CR-0001 AC6 | Start Claude Code in the container's terminal, sign in, and ask it a simple question about the repository. To check whether a sign-in host is needed, remove it from the allowlist in a copy, rebuild, and sign in again. | Sign-in and the request work with the hosts on the allowlist; any host found not to be needed is removed by a follow-up change. |
| M11 | CR-0001 AC9 | With VS Code attached to the container, open the Claude Code extension and ask it a simple question. In the container, compare `/usr/local/etc/allowed-domains.txt` (the copy in use) with the list in the threat model. | The extension works, and the allowlist in use matches the threat model, with no extension marketplace hosts (unless the fallback in ADR-0004 was needed and recorded). |

CR-0000 AC3 (CI passes on the template) and AC4 (actions pinned, token read-only) are
verified by the CI jobs on the CR-0000 pull request; AC4's job is
`cr0000-ac4-actions-pinned`. CR-0001 AC7 (trivial-change rule) and AC8 (release
criteria) are verified by CR-0001's closing pull request and release.

## Release criteria for the template

A release is tagged only when every CR it contains is Done, with all its acceptance
criteria verified, including manual checks. It may also include work whose CR isn't
Done, as long as each such changelog entry is marked **experimental** and says what isn't
verified yet (ADR-0002).

## Traceability

Acceptance tests and CI checks are named after the CR and criterion they verify, for
example `test_cr0003_ac2_resumes_partial_download` or `cr0000-ac4-actions-pinned`.
To validate the project:

1. List the acceptance criteria of every CR in `docs/cr/` with status Done.
2. Run the command above, and work through the manual checks.
3. Search the tests, the CI workflow and this file for each criterion's ID (for
   example `cr0003_ac2`, `cr0003-ac2` or `CR-0003 AC2`). A criterion with no match has
   no verification.
