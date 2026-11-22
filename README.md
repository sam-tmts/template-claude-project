# template-claude-project

A GitHub template for hobby software projects developed with coding agents such as
Claude Code, set up so that others can use the same approach. Its principles, in
priority order, are in [`CLAUDE.md`](CLAUDE.md): elegance through simplicity; easy to
use, fun to use; security in proportion to risk; learn from others, keep improving;
document clearly and concisely; automate what repeats.

Every project started from it works the same way:

- **Change requests drive every change**, each with acceptance criteria that say how
  they're verified ([ADR-0001](docs/adr/ADR-0001-change-requests-in-repo.md)).
- **Tests come first**, and every criterion is traceable to a test or a manual check
  ([test plan](docs/test-plan.md)).
- **Releases follow semver**, with a hand-written changelog
  ([ADR-0002](docs/adr/ADR-0002-semver-and-changelog.md)).
- **Real secrets never enter the repository**
  ([ADR-0003](docs/adr/ADR-0003-secrets-outside-repository.md)).
- **Agents work in Claude Code's sandbox**, in a dedicated developer account
  ([ADR-0004](docs/adr/ADR-0004-sandboxed-development.md)).

## What's inside

| Path | What it is |
|------|------------|
| `CLAUDE.md` | Principles, workflow and rules every agent session reads first |
| `.claude/` | Sandbox and permission settings, and the `reviewer` and `test-writer` subagents |
| `.github/` | CI, pull request template, CR issue form, Dependabot, CODEOWNERS |
| `docs/` | CRs, ADRs, test plan, threat model, architecture, dependencies, retrospectives |
| `CHANGELOG.md`, `SECURITY.md`, `LICENSE` | Release notes, security policy, MIT licence |

## One-time setup on your computer

1. **Use a dedicated developer account**, with no access to your personal files, for
   all development.
2. **Install [Claude Code](https://code.claude.com/docs/en/overview)** in that account.
   Claude's commands run in a sandbox; `git push` is the only exception, and Claude asks
   before every push ([details](docs/adr/ADR-0004-sandboxed-development.md)). On Linux,
   and on Windows through WSL2, run `/sandbox` in Claude Code to see what to install.
3. **Install git** (on macOS: `xcode-select --install`), and create a
   [fine-grained personal access token](https://github.com/settings/personal-access-tokens)
   limited to your project repositories, with a short expiry and only Contents (read
   and write). Push once from an ordinary terminal and paste the token when asked for a
   password; git stores it for later pushes, including Claude's.

## Starting a new project

1. On GitHub, click **Use this template** → **Create a new repository**.
2. In the new repository's settings:
   - **Rules → Rulesets:** protect the default branch: require a pull request, block
     force pushes, restrict deletions, and require these status checks to pass:
     `Secret scan (gitleaks)`, `Markdown lint`, `Actions pinned and token read-only`
     and `PR references a CR`. (GitHub lists a check here only after it has run once,
     so add them after the first pull request.)
   - **Security → Advanced Security:** turn on Dependabot alerts, **Secret
     Protection** and its **Push protection** option, and private vulnerability
     reporting (which `SECURITY.md` points to).
   - **Actions → General** (under **Actions** in the Settings sidebar): require
     approval for fork pull request workflows from all external contributors, and set
     workflow permissions to read-only.
3. Clone it over HTTPS, start `claude` in the folder, and run `/sandbox` to confirm the
   sandbox is on.
   Open pull requests on GitHub's website: after a push, git prints the link.
4. Write the project's first CR (see below) and work through it as `CLAUDE.md`
   describes.

## What a project's first CR changes

- **Names:** the owner wherever the template names one: `.github/CODEOWNERS`,
  `CLAUDE.md`, `SECURITY.md` and `LICENSE`.
- **Changelog:** a fresh `CHANGELOG.md` with an empty `Unreleased` section. Keep
  `docs/cr/` as the record of how the template was built.
- **README:** a description of the project, replacing this one.
- **Tooling:** the language toolchain, build and test jobs in CI, Dependabot entries
  for the project's packages, and any hosts the sandbox must allow.
- **`CLAUDE.md`:** the project's commands and notes.
- **Docs:** the test strategy and "run everything" command in `docs/test-plan.md`,
  and the project's own sections in `docs/architecture.md`, `docs/threat-model.md` and
  `docs/dependencies.md`.

## Notes

Dependabot's pull requests don't need a CR: they are routine updates of already
approved dependencies, so the CI check for a CR reference skips them. The owner still
reviews and merges each one.

## Licence

[MIT](LICENSE). Copyright (c) 2026 Samuel Taylor (sam-tmts).
