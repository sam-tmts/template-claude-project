# CR-0000: Establish the project template repository

| Field         | Value                                     |
|---------------|-------------------------------------------|
| Status        | Done                                      |
| Author        | sam-tmts (drafted with Claude)            |
| Created       | 2026-11-20, rewritten 2026-11-21          |
| Semver impact | Initial release of the template: v0.1.0   |

## Why

A template for exploring hobby software projects with agentic development, built so
that others can use the same approach. It sets up a light, consistent way of working:
change requests drive every change, decisions are recorded, tests come first, releases
follow semver, and secrets stay out of the repository.

This first version is deliberately lean. The dev container that will contain agents
on the owner's computer is its own CR (CR-0001), so it can be reviewed on its own.

## Scope

**In:**

- Ways of working: `CLAUDE.md` (agent instructions), `.claude/settings.json`
  (permission rules), and the `reviewer` and `test-writer` subagents.
- Templates: change request (in this lighter format), ADR, pull request, CR issue form.
- Decisions: ADR-0001 (CRs live in the repo), ADR-0002 (semver and changelog),
  ADR-0003 (real secrets never enter the repository).
- Documentation stubs for projects to fill: architecture, threat model, dependency
  register, and a test plan (strategy, how to run everything, manual checks,
  traceability).
- Repository basics: README, MIT licence, changelog, security policy, `.gitignore`,
  `.gitattributes`, `.editorconfig`.
- CI: secret scan (gitleaks), markdown lint, a check that each pull request
  references an existing CR, and a check that every third-party action is pinned to a
  full commit SHA. Dependabot for GitHub Actions; CODEOWNERS.

**Out:**

- The dev container, firewall and local secret-scanning hook: CR-0001.
- A separate GitHub account for the agent, so the owner can formally approve its pull
  requests: a later CR.
- Language-specific tooling: each project's own first CR.

## Design notes

Start lean and grow from experience: only what every project needs on day one, with
the dev container as a separate CR because it carries most of the security risk and
deserves its own review. CI checks run on GitHub, so they work the same whatever the
collaborator's operating system.

ADRs created: ADR-0001 (CRs live in the repo), ADR-0002 (semver and changelog),
ADR-0003 (real secrets never enter the repository). Relies on: none.

## Acceptance criteria

- [x] AC1: A pull request whose description doesn't reference a CR, or references one
      with no file in `docs/cr/`, fails CI.
      *Verified by:* manual check M1 (a throwaway pull request for each case).
- [x] AC2: A pushed commit containing a fake secret is stopped, by GitHub push
      protection or by the CI secret scan.
      *Verified by:* manual check M2.
- [x] AC3: CI passes on the template itself (secret scan, markdown lint, CR check,
      action pinning).
      *Verified by:* CI on this CR's pull request.
- [x] AC4: Every third-party GitHub Action is pinned to a full commit SHA, and the
      workflow token is read-only.
      *Verified by:* CI check `cr0000-ac4-actions-pinned`.
- [x] AC5: A direct push to `main` is rejected.
      *Verified by:* manual check M3 (first done on 2026-11-21).
- [x] AC6: A repository created from the template has all of the above once the
      repository settings listed in its README are applied (GitHub doesn't copy
      settings from a template), and its README says what a project must change first
      (owner name, changelog, project details).
      *Verified by:* manual check M4.

Manual checks M1 to M4 are written up in `docs/test-plan.md`.

## Constraints and risks

- The repository is public: nothing personal beyond the owner's name and GitHub id, and
  no secrets.
- Must work the same for Mac and Windows collaborators.
- Until CR-0001's container lands, Claude Code is not run on the owner's computer
  against these repositories. Work continues from Claude's cloud workspace, as for this
  CR. The permission rules in `.claude/settings.json` are therefore checked under
  CR-0001.
- Without a separate agent account, GitHub can't require the owner's approval on pull
  requests; the ruleset requires a pull request, and the owner merges.

## Approval log

| Gate | Date | By | Notes |
|------|------|----|-------|
| Original CR approved | 2026-11-21 | Sam (sam-tmts) | Detailed version, superseded by this rewrite |
| Original plan approved | 2026-11-21 | Sam (sam-tmts) | Superseded |
| Rewrite approved | 2026-11-21 | Sam (sam-tmts) | Lean scope; container moved to CR-0001 |
| Plan approved | 2026-11-21 | Sam (sam-tmts) | Plan in the PR description |
| AC6 rewording approved | 2026-11-21 | Sam (sam-tmts) | Review finding: settings aren't copied from a template |
| PR merged | 2026-11-21 | Sam (sam-tmts) | PR #1, merge commit 5656df3; M1 to M3 done, M4 after release |
| Released (v0.1.0) | 2026-11-21 | Sam (sam-tmts) | Tag v0.1.0 on merge commit 07a4ad8 |
| M4 done, CR closed | 2026-11-21 | Sam (sam-tmts) | Repository created from the template; M1 and M3 repeated there as expected. Found two README errors in the settings steps, fixed in the closing PR |
