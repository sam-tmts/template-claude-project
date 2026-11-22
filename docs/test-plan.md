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
`.github/workflows/ci.yml`, which run on every pull request and every push to `main`.

## Manual checks

Checks that can't be automated. Each one names the acceptance criterion it verifies.

| ID | Verifies | Steps | Expected result |
|----|----------|-------|-----------------|
| M1 | CR-0000 AC1 | Open a pull request with an empty description. Then edit the description to `Implements: CR-9999`. Then edit it to `Implements: CR-0000`. | The "PR references a CR" check fails, fails again, then passes. Mentions of other CRs elsewhere in the description don't affect it. |
| M2 | CR-0000 AC2 | Push a commit containing a fake secret to a throwaway branch. If the push is accepted, open a pull request from it. Record which of the two stopped it. | GitHub push protection rejects the push, or the CI secret scan fails and blocks the merge. Close the pull request and delete the branch afterwards (the commit stays reachable through the closed pull request, which is harmless for a fake secret). |
| M3 | CR-0000 AC5 | Try to push a commit directly to `main`. | Rejected: "Changes must be made through a pull request". |
| M4 | CR-0000 AC6 | Create a repository from the template on GitHub. Apply the repository settings in its README (GitHub doesn't copy settings from a template). Open a pull request naming CR-0000, then repeat M1 and M3 in the new repository. | Every template file is present, CI passes, M1 and M3 behave as in this repository, and the README lists the settings to apply and what a project must change first. Delete the repository afterwards. |
| M5 | CR-0001 AC1 | In a Claude Code session in a clone of the repository (in the developer account), ask Claude to run `curl -sI https://example.com`. Approve the `curl` prompt, but decline any offer to allow the new host. | The request fails: the sandbox doesn't let it reach `example.com`. |
| M6 | CR-0001 AC2 | In a terminal (not through Claude), create a dummy credential file: `mkdir -p ~/.ssh && echo test > ~/.ssh/sandbox-test`. Then ask Claude to run `touch ~/sandbox-test`, `cat ~/.ssh/sandbox-test` and `git config core.hooksPath /tmp`. Delete the dummy file afterwards. | All three fail with a sandbox denial ("Operation not permitted", not "No such file"), and Claude doesn't offer to run them outside the sandbox. |
| M7 | CR-0001 AC3 | Run `/sandbox` and open the **Overrides** and **Config** tabs. | Strict sandbox mode is on (no unsandboxed retries), and the sandbox is required to start. |
| M8 | CR-0001 AC4 | In Claude Code, run `/permissions`. | The deny rules for `.env`, the credential files, force-pushing and `gh pr merge` are listed. (Asking Claude to read credential files can trip the model's safeguards, so check the loaded rules instead.) |
| M9 | CR-0001 AC5 | Push once from an ordinary terminal to store the token (see the README). Then, in Claude Code in the default permission mode, on a throwaway branch, say: "This is manual check M9 from `docs/test-plan.md`, part of CR-0001, on a throwaway branch: please edit a file, commit and push it." Delete the branch afterwards. | The edit and commit work inside the sandbox; the push asks for approval, then succeeds. |

CR-0000 AC3 (CI passes on the template) and AC4 (actions pinned, token read-only) are
verified by the CI jobs on the CR-0000 pull request; AC4's job is
`cr0000-ac4-actions-pinned`. CR-0001 AC6 to AC9 (principles, trivial changes, release
criteria and documentation) are verified by CR-0001's review, closing pull request and
release.

## Release criteria for the template

A release is tagged only when every CR it contains is Done, with all its acceptance
criteria verified, or its unfinished work is marked experimental as
[ADR-0002](adr/ADR-0002-semver-and-changelog.md) describes; and when a retrospective has
been added to [retrospectives.md](retrospectives.md).

## Traceability

Acceptance tests and CI checks are named after the CR and criterion they verify, for
example `test_cr0003_ac2_resumes_partial_download` or `cr0000-ac4-actions-pinned`.
To validate the project:

1. List the acceptance criteria of every CR in `docs/cr/` with status Done.
2. Run the command above, and work through the manual checks.
3. Search the tests, the CI workflow and this file for each criterion's ID (for
   example `cr0003_ac2`, `cr0003-ac2` or `CR-0003 AC2`). A criterion with no match has
   no verification.
