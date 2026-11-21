# Security

## Reporting a problem

Please report security problems privately using GitHub's **Report a vulnerability**
button on the repository's **Security** tab, not in a public issue. Reports are read by
the owner, sam-tmts, and acknowledged as soon as practical.

Only the latest release is supported.

## How secrets are handled

- Real credentials (API keys, OAuth tokens, passwords) are never committed to the
  repository. They live in the operating system's credential store, such as the macOS
  Keychain, and are used only when the owner runs the software. See
  `docs/adr/ADR-0003-secrets-outside-repository.md`.
- Tests use mocks and recorded fixtures, never live credentials.
- Every pull request and every push to `main` is scanned for secrets by gitleaks in CI.
  GitHub secret scanning and push protection are also enabled.

## How agents are contained

Coding agents work inside a dev container that sees only the project folder and can
reach only an allowlist of network hosts over HTTPS, run from a dedicated developer
account with no access to personal data. Every commit made in the container is scanned
for secrets before it is created. The details, and what this does and doesn't protect
against, are in `docs/threat-model.md` and ADR-0004.
