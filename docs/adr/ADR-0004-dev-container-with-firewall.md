# ADR-0004: Agents run in a dev container with a default-deny firewall

| Field      | Value                    |
|------------|--------------------------|
| Status     | Accepted                 |
| Date       | 2026-11-21               |
| Deciders   | Samuel Taylor (sam-tmts) |
| Related CR | CR-0001                  |

## Context

Coding agents run commands as the user who starts them. A developer's computer may hold
sensitive personal data that an agent must never be able to reach, whether by mistake,
through a malicious dependency or through prompt injection. Collaborators use both macOS
and Windows and need the same toolchain.

## Decision

All development, by people and agents, happens inside the dev container defined in
`.devcontainer/`, run from a dedicated developer account on the host that has no access
to personal data:

- Only the project folder is mounted from the host.
- Host git credentials, the host SSH agent and VS Code's git sign-in passthrough are not
  available in the container. GitHub access from inside uses a fine-grained token
  limited to the one repository.
- Outbound traffic is denied by default, and the deny is applied before anything else
  so the firewall fails closed. Allowed: HTTPS to GitHub's published address ranges and
  to the hosts listed in `.devcontainer/allowed-domains.txt`, and DNS to the container's
  own resolver.
- VS Code extensions are downloaded on the host and copied into the container, pinned
  to a version with auto-update off, so the container never contacts the extension
  marketplace.
- The container is based on Anthropic's reference dev container, pinned to a recorded
  upstream commit, with differences documented in the Dockerfile header. Images are
  pinned by digest and kept up to date by Dependabot.
- Adding a host to the allowlist is a change to a protected path and needs a CR.

## Consequences

- An agent mistake or compromise can directly reach only the project folder and the
  allowlisted hosts. The project folder is shared with the host, though, so files written
  there (for example `devcontainer.json`, `.vscode/tasks.json` or git hooks) can run code
  on the host later. The rules for working on the host in the README, and the threat
  model's "Code run on the host" row, exist for this.
- Mac and Windows collaborators get an identical environment.
- Desktop-only tools (for example an emulator with a GUI) run on the host and pick up
  build output from the project folder.
- Software that must use real credentials is run by the developer on the host
  (ADR-0003).
- If a project ever needs an extension that can't be installed from the host, the
  fallback is to allow the extension marketplace hosts. They sit on shared delivery
  networks, so allowing their addresses also reaches other sites; that would be recorded
  in the threat model as an accepted risk.

## Alternatives considered

- **Claude Code's built-in sandbox on the host.** Lighter, but the agent and its tools
  still run as a host user on a machine that may hold personal data.
- **A full virtual machine.** Stronger isolation but heavier, slower and harder for
  collaborators to reproduce.
- **The repository kept in a container volume instead of a shared folder.** Removes the
  "code run on the host" risk, but host tools (such as an emulator) can't see build
  output, and the code is harder to back up.
