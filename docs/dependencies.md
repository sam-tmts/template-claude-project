# Dependency register

Every dependency, including build tools and GitHub Actions, has an entry here. A new
dependency is part of a CR and needs the owner's approval; the entry is what gets
reviewed. Exact versions are pinned in the files named, not here.

Each entry records: **purpose**, **where it's pinned**, **alternatives considered**,
**licence** and **maintenance health**.

> **Template note.** These are the template's own dependencies, all used in CI. Each
> project adds its toolchain and libraries in its first CR and later CRs.

## gitleaks

- **Purpose:** secret scanning in CI.
- **Pinned in:** `.github/workflows/ci.yml` (exact version and SHA-256 checksum of the
  release archive).
- **Alternatives:** GitHub secret scanning alone (covers fewer secret formats);
  `trufflehog` (heavier).
- **Licence:** MIT. **Health:** widely used; actively maintained.

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
