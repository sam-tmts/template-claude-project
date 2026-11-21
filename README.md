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
- **Agents work inside a dev container** that sees only the project folder and can
  reach only an allowlist of hosts
  ([ADR-0004](docs/adr/ADR-0004-dev-container-with-firewall.md)).

## What's inside

| Path | What it is |
|------|------------|
| `CLAUDE.md` | Instructions every agent session reads first: workflow, rules, conventions |
| `.claude/` | Claude Code permission rules, and the `reviewer` and `test-writer` subagents |
| `.devcontainer/` | The dev container, its firewall, its host allowlist, and a script to verify it |
| `.githooks/pre-commit` | Scans every commit made in the container for secrets |
| `.github/` | CI, pull request template, CR issue form, Dependabot, CODEOWNERS |
| `docs/cr/` | Change requests, and the template for new ones |
| `docs/adr/` | Architecture decision records, and the template for new ones |
| `docs/test-plan.md` | Test strategy, manual checks, and how to validate the project |
| `docs/` (other) | Architecture, threat model and dependency register, for each project to fill |
| `CHANGELOG.md`, `SECURITY.md`, `LICENSE` | Release notes, security policy, MIT licence |

## One-time setup on your computer

Install as little as possible on the computer itself: language toolchains live inside
the dev container.

1. **Use a dedicated developer account.** Create a separate standard (non-admin) user
   account for development, with no access to your personal files, and do everything
   below in it.
2. **Install a container runtime.** [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   works on macOS and Windows and is what VS Code's Dev Containers feature is built
   around. In its settings, under **Resources → File sharing**, remove the default
   locations and share only the folder you keep projects in (for example `~/Projects`).
3. **Install [VS Code](https://code.visualstudio.com/) and its Dev Containers
   extension.** Don't install the Claude Code extension on the computer itself: it is
   installed inside the container automatically.
4. **Add these to VS Code's user settings** (Command Palette → "Preferences: Open User
   Settings (JSON)"):

   ```json
   "dev.containers.copyGitConfig": false,
   "dev.containers.gitCredentialHelperConfigLocation": "none",
   "remote.downloadExtensionsLocally": true
   ```

   The first two stop VS Code sharing your git credentials with containers. The third
   makes VS Code download extensions on your computer and copy them in, so the container
   never contacts the extension marketplace. These settings are per user and per
   machine, so every developer needs them. `verify-container.sh` checks that no git
   credentials reach the container.
5. **Don't trust project folders in VS Code on the host.** If VS Code asks whether you
   trust the authors of a folder opened on the host, choose **No** (Restricted Mode).
   Inside the container, trusting the folder is fine.
6. **Install git**, needed once to clone a repository (on macOS:
   `xcode-select --install`).

## Rules for working on the host

The project folder is shared between your computer and the container, so a file written
inside the container can later run on your computer. Three rules close that gap:

1. **Open the project straight into the container**, with **Dev Containers: Open Folder
   in Container…** from the Command Palette, or from VS Code's list of recent
   containers. Opening the folder on the host first, even briefly, lets VS Code's git
   support run on the host against the shared `.git/`. Don't run tasks or scripts from
   the project on the host.
2. **Review changes to `.devcontainer/`, `.vscode/` and `.githooks/` before rebuilding or
   reopening the container.** VS Code runs some settings in `devcontainer.json` on the
   host, and `.vscode/tasks.json` can run commands when the folder opens.
3. **After the first clone, don't run git on the host in these folders.** The container
   can write to `.git/`, and git on the host would run any hooks or settings it finds
   there. Use git inside the container, or GitHub's website.

## Starting a new project

1. On GitHub, click **Use this template** → **Create a new repository**.
2. In the new repository's settings:
   - **Rules → Rulesets:** protect the default branch: require a pull request, block
     force pushes, restrict deletions, and require these status checks to pass:
     `Secret scan (gitleaks)`, `Markdown lint`, `Actions pinned and token read-only`
     and `PR references a CR`. (GitHub lists a check here only after it has run once,
     so add them after the first pull request.)
   - **Security → Advanced Security:** turn on Dependabot alerts, **Secret
     Protection** (GitHub's name for secret scanning) and its **Push protection**
     option, and private vulnerability reporting (which `SECURITY.md` points to).
   - **Actions → General** (under **Actions** in the Settings sidebar, not the
     top-level General page): under "Approval for running fork pull request workflows
     from contributors", require approval for all external contributors; under
     "Workflow permissions", choose read-only and save.
3. Clone the repository into your projects folder, then in VS Code run **Dev
   Containers: Open Folder in Container…** and choose that folder. The first build
   takes a few minutes; the firewall is set up every time the container starts. Always
   start the container from VS Code: started any other way, it has no firewall.
4. In the container's terminal, run `bash .devcontainer/verify-container.sh`. Don't go
   on until every check passes.
5. Still in the container, set your git identity for this repository, using your
   GitHub noreply address:

   ```sh
   git config user.name "Your Name"
   git config user.email "12345678+your-id@users.noreply.github.com"
   ```

6. Create a [fine-grained personal access token](https://github.com/settings/personal-access-tokens)
   for this one repository, with a short expiry and only Contents and Pull requests
   (read and write). Never grant Workflows or Administration. Sign in with it inside the
   container: `gh auth login`, then `gh auth setup-git`.
7. Start Claude Code with `claude` in the container's terminal (or open the Claude Code
   extension in VS Code) and sign in.
8. Write the project's first CR (see below) and work through it as `CLAUDE.md`
   describes.

## What a project's first CR changes

- **Names:** the owner wherever the template names one: `.github/CODEOWNERS`,
  `CLAUDE.md`, `SECURITY.md` and `LICENSE`.
- **Changelog:** a fresh `CHANGELOG.md` with an empty `Unreleased` section. Keep
  `docs/cr/CR-0000-template-repository.md` as the record of how the template was built.
- **README:** a description of the project, replacing this one.
- **Tooling:** the language toolchain in `.devcontainer/Dockerfile`, any package
  registries or APIs in `.devcontainer/allowed-domains.txt`, build and test jobs in CI,
  and Dependabot entries for the project's packages.
- **`CLAUDE.md`:** the project's commands and notes.
- **Versioning:** the single place the version number lives (ADR-0002).
- **Docs:** the test strategy and "run everything" command in `docs/test-plan.md`; the
  system context and containers in `docs/architecture.md`; the project's own assets and
  threats in `docs/threat-model.md`; its dependencies in `docs/dependencies.md`.

## Verifying a project

The dev container checks itself: run `bash .devcontainer/verify-container.sh` inside
it after any change to `.devcontainer/` or to your computer's setup. The manual checks
it can't do are listed in `docs/test-plan.md`.

For the project as a whole, `docs/test-plan.md` explains how: run the single command that runs every automated
check, work through the manual checks, and confirm every acceptance criterion of every
completed CR is covered by a named test or a listed manual check.

Dependabot's pull requests don't need a CR: they are routine updates of already
approved dependencies, so the CI check for a CR reference skips them. The owner still
reviews and merges each one.

## Licence

[MIT](LICENSE). Copyright (c) 2026 Samuel Taylor (sam-tmts).
