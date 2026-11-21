# ADR-0003: Real secrets never enter the repository

| Field      | Value                    |
|------------|--------------------------|
| Status     | Accepted                 |
| Date       | 2026-11-21               |
| Deciders   | Samuel Taylor (sam-tmts) |
| Related CR | CR-0000                  |

## Context

Projects will use real credentials, such as API keys and OAuth tokens for online
services. Anything in the project folder can be read by a coding agent and sent to the
model, and anything committed to a public repository is public permanently.

## Decision

- Real credentials live only in the operating system's credential store (for example
  the macOS Keychain) and are used only when the owner runs the software.
- Code reads credentials at runtime through a credential-store library, never from files
  in the project folder.
- Tests use mocks and recorded fixtures with any secrets removed.
- gitleaks scans every pull request and every push to `main` in CI; GitHub secret
  scanning and push protection are enabled.

## Consequences

- An agent can build and test everything without seeing a real secret.
- Running against a live service is a deliberate step the owner takes.
- Recorded fixtures must be checked for secrets and personal data before they are
  committed.

## Alternatives considered

- **`.env` files in the project folder, ignored by git.** Common, but an agent can read
  them and a mistaken `git add -f` publishes them.
- **Secrets passed in as environment variables.** Convenient, but readable by any
  process the agent runs.
