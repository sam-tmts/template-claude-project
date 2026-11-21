# Dependency register

Every dependency, including build tools and GitHub Actions, has an entry here. A new
dependency is part of a CR and needs the owner's approval; the entry is what gets
reviewed. Exact versions are pinned in the files named, not here.

Each entry records: **purpose**, **where it's pinned**, **alternatives considered**,
**licence** and **maintenance health**.

> **Template note.** These are the template's own dependencies, in CI and in the dev
> container. Each project adds its toolchain and libraries in its first CR and later
> CRs.

## gitleaks

- **Purpose:** secret scanning, in CI and in the pre-commit hook inside the dev
  container.
- **Pinned in:** `.github/workflows/ci.yml` (exact version and SHA-256 checksum of the
  release archive, updated by hand; see the backlog issue) and `.devcontainer/Dockerfile`
  (official image `ghcr.io/gitleaks/gitleaks`, updated by Dependabot).
- **Alternatives:** GitHub secret scanning alone (covers fewer secret formats);
  `trufflehog` (heavier).
- **Licence:** MIT. **Health:** widely used; actively maintained.

## Node.js base image (`node`, Debian bookworm)

- **Purpose:** base operating system for the dev container; Node.js is needed to run
  Claude Code.
- **Pinned in:** `.devcontainer/Dockerfile` (`FROM` line); Dependabot proposes updates.
- **Alternatives:** Microsoft's `devcontainers/base` image plus a Node install step
  (one more moving part).
- **Licence:** MIT (Node.js); Debian packages under their own free licences.
- **Health:** official Docker image maintained by the Node.js Docker team.

## Claude Code (`@anthropic-ai/claude-code`)

- **Purpose:** the coding agent, installed in the dev container.
- **Pinned in:** `.devcontainer/devcontainer.json` (`CLAUDE_CODE_VERSION` build
  argument). Auto-update is switched off in the container, so the version only changes
  through a reviewed CR.
- **Alternatives:** Anthropic's native installer (the npm package can be pinned exactly).
- **Licence:** proprietary, Anthropic commercial terms. **Health:** maintained by
  Anthropic; frequent releases.

## Claude Code VS Code extension (`anthropic.claude-code`)

- **Purpose:** Claude Code inside VS Code, attached to the dev container.
- **Pinned in:** `.devcontainer/devcontainer.json`. Downloaded on the host and copied
  into the container; extension auto-update is off.
- **Licence:** Anthropic commercial terms. **Health:** maintained by Anthropic.

## Debian packages (apt)

- **Purpose:** `git`, `gh` (GitHub CLI), `iptables`, `ipset`, `iproute2`, `dnsutils`,
  `aggregate`, `jq`, `curl`, `sudo`, `less`, `procps`, `nano`, `ca-certificates`. The
  firewall needs `iptables`, `ipset`, `dnsutils`, `aggregate`, `jq` and `curl`.
- **Pinned in:** `.devcontainer/Dockerfile`; versions follow the base image's Debian
  release.
- **Licence:** various free software licences. **Health:** Debian security team.

## `actions/checkout`

- **Purpose:** check out the repository in CI.
- **Pinned in:** `.github/workflows/ci.yml` (full commit SHA, tag in a comment).
- **Alternatives:** none; it is GitHub's own action.
- **Licence:** MIT. **Health:** maintained by GitHub.

## `DavidAnson/markdownlint-cli2-action`

- **Purpose:** lint the Markdown documentation in CI.
- **Pinned in:** `.github/workflows/ci.yml` (full commit SHA, tag in a comment).
- **Alternatives:** running `markdownlint-cli2` through npm in a script step.
- **Licence:** MIT. **Health:** maintained by the author of markdownlint; active.
