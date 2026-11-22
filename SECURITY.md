# Security

## Reporting a problem

Please report security problems privately using GitHub's **Report a vulnerability**
button on the repository's **Security** tab, not in a public issue. Reports are read by
the owner, sam-tmts, and acknowledged as soon as practical.

Only the latest release is supported.

## How this project stays secure

- Real secrets never enter the repository:
  [ADR-0003](docs/adr/ADR-0003-secrets-outside-repository.md).
- Coding agents work in Claude Code's sandbox, in a dedicated developer account:
  [ADR-0004](docs/adr/ADR-0004-sandboxed-development.md).
- The risks, how each is handled, and the known limitations:
  [threat model](docs/threat-model.md).
