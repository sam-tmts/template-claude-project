# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Every pull
request adds its entries under `Unreleased`; a release moves them under a version
heading and is tagged `vX.Y.Z`.

## [Unreleased]

## [0.2.0] - 2026-11-22

### Added

- Principles in `CLAUDE.md`, in priority order, and a rule to challenge complexity
  before building; the reviewer's checks follow the principles (CR-0001).
- Claude Code's sandbox in strict mode, for working safely in a dedicated developer
  account (CR-0001).
- A lighter path for trivial changes, and release criteria with a retrospective before
  each release (CR-0001).

### Changed

- Documentation trimmed so each fact lives in one place: SECURITY.md and the README
  link to the ADRs and threat model instead of repeating them (CR-0001).

### Fixed

- README: the repository settings steps now use GitHub's current names (Secret
  Protection) and say where the Actions settings are (CR-0000).

## [0.1.0] - 2026-11-21

### Added

- Repository basics: `.gitignore`, `.gitattributes` (LF line endings), `.editorconfig`,
  this changelog and `SECURITY.md` (CR-0000).
- Documentation: CR and ADR templates, ADR-0001 to ADR-0003, CR-0000, test plan, and
  stubs for the architecture, threat model and dependency register (CR-0000).
- Agent setup: `CLAUDE.md`, Claude Code permission rules, and the reviewer and
  test-writer subagents (CR-0000).
- GitHub configuration: CI (secret scan, markdown lint, CR reference check, action
  pinning check), pull request template, CR issue form, Dependabot and CODEOWNERS
  (CR-0000).
- README explaining how to start a project from the template (CR-0000).

[Unreleased]: https://github.com/sam-tmts/template-claude-project/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/sam-tmts/template-claude-project/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/sam-tmts/template-claude-project/releases/tag/v0.1.0
