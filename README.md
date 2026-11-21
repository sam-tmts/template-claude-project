# template-claude-project

A GitHub template for hobby software projects developed with coding agents such as
Claude Code, set up so that others can use the same approach. Every project started from
it works the same way:

- **Change requests drive every change.** Each change starts as a CR file in `docs/cr/`
  saying why, what's in and out of scope, and the acceptance criteria, each with how
  it's verified. The implementation plan is agreed before work starts and kept in the
  pull request ([ADR-0001](docs/adr/ADR-0001-change-requests-in-repo.md)).
- **Tests come first.** Acceptance tests are written from the CR before the code, and
  carry the CR and criterion they verify. See [the test plan](docs/test-plan.md).
- **Decisions are written down** as ADRs in `docs/adr/`.
- **Releases follow semver**, with a hand-written changelog
  ([ADR-0002](docs/adr/ADR-0002-semver-and-changelog.md)).
- **Real secrets never enter the repository**
  ([ADR-0003](docs/adr/ADR-0003-secrets-outside-repository.md)).

## What's inside

| Path | What it is |
|------|------------|
| `CLAUDE.md` | Instructions every agent session reads first: workflow, rules, conventions |
| `.claude/` | Claude Code permission rules, and the `reviewer` and `test-writer` subagents |
| `.github/` | CI, pull request template, CR issue form, Dependabot, CODEOWNERS |
| `docs/cr/` | Change requests, and the template for new ones |
| `docs/adr/` | Architecture decision records, and the template for new ones |
| `docs/test-plan.md` | Test strategy, manual checks, and how to validate the project |
| `docs/` (other) | Architecture, threat model and dependency register, for each project to fill |
| `CHANGELOG.md`, `SECURITY.md`, `LICENSE` | Release notes, security policy, MIT licence |

## Before you start: running agents safely

The next version of this template (CR-0001) adds a dev container that keeps coding
agents away from everything on your computer except the project folder. Until then,
don't run Claude Code on your own computer against a repository made from this
template.

## Starting a new project

1. On GitHub, click **Use this template** → **Create a new repository**.
2. In the new repository's settings:
   - **Rules → Rulesets:** protect the default branch: require a pull request, block
     force pushes, restrict deletions.
   - **Advanced Security:** turn on Dependabot alerts, secret scanning and push
     protection.
   - **Actions → General:** require approval for workflows from all outside
     contributors, and set workflow permissions to read-only.
3. Write the project's first CR (see below) and work through it as `CLAUDE.md`
   describes.

## What a project's first CR changes

- **Names:** the owner wherever the template names one: `.github/CODEOWNERS`,
  `CLAUDE.md`, `SECURITY.md` and `LICENSE`.
- **Changelog:** a fresh `CHANGELOG.md` with an empty `Unreleased` section. Keep
  `docs/cr/CR-0000-template-repository.md` as the record of how the template was built.
- **README:** a description of the project, replacing this one.
- **Tooling:** the language toolchain, build and test jobs in CI, and Dependabot entries
  for the project's packages.
- **`CLAUDE.md`:** the project's commands and notes.
- **Versioning:** the single place the version number lives (ADR-0002).
- **Docs:** the test strategy and "run everything" command in `docs/test-plan.md`; the
  system context and containers in `docs/architecture.md`; the project's own assets and
  threats in `docs/threat-model.md`; its dependencies in `docs/dependencies.md`.

## Verifying a project

`docs/test-plan.md` explains how: run the single command that runs every automated
check, work through the manual checks, and confirm every acceptance criterion of every
completed CR is covered by a named test or a listed manual check.

Dependabot's pull requests don't need a CR: they are routine updates of already
approved dependencies, so the CI check for a CR reference skips them. The owner still
reviews and merges each one.

## Licence

[MIT](LICENSE). Copyright (c) 2026 Samuel Taylor (sam-tmts).
