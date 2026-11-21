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
| M1 | CR-0000 AC1 | Open a pull request whose description names no CR. Then edit the description to name `CR-9999`. Then edit it to name `CR-0000`. | The "PR references a CR" check fails, fails again, then passes. |
| M2 | CR-0000 AC2 | Push a commit containing a fake, randomly generated GitHub token to a throwaway branch. If the push is accepted, open a pull request from it. | GitHub push protection rejects the push, or the CI secret scan fails on the pull request. Delete the branch afterwards. |
| M3 | CR-0000 AC5 | Try to push a commit directly to `main`. | Rejected: "Changes must be made through a pull request". |
| M4 | CR-0000 AC6 | Create a repository from the template on GitHub, and open a pull request in it naming CR-0000. Read its README. | Every template file is present, CI passes, and the README lists what a project must change first. Delete the repository afterwards. |

## Traceability

Acceptance tests and CI checks are named after the CR and criterion they verify, for
example `test_cr0003_ac2_resumes_partial_download` or `cr0000-ac4-actions-pinned`.
To validate the project:

1. List the acceptance criteria of every CR in `docs/cr/` with status Done.
2. Run the command above, and work through the manual checks.
3. Search the tests, the CI workflow and this file for each criterion's ID (for
   example `cr0003_ac2`, `cr0003-ac2` or `CR-0003 AC2`). A criterion with no match has
   no verification.
