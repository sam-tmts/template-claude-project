# ADR-0004: Agents run in Claude Code's sandbox, in a dedicated developer account

| Field      | Value                    |
|------------|--------------------------|
| Status     | Accepted                 |
| Date       | 2026-11-22               |
| Deciders   | Samuel Taylor (sam-tmts) |
| Related CR | CR-0001                  |

## Context

Coding agents run commands as the user who starts them. A developer's computer may hold
personal data that an agent must never reach, by mistake, through a malicious
dependency or through prompt injection.

## Decision

- Development happens in a dedicated developer account on the computer, with no access
  to personal data.
- Claude Code runs there with its built-in sandbox on, in strict mode (set in
  `.claude/settings.json`): shell commands can write only inside the project, can't
  read the account's credential locations, can reach only allowlisted hosts, can't be
  retried outside the sandbox, and Claude Code won't start if the sandbox can't.
- `git push` is the one command that runs outside the sandbox, because pushing needs
  the stored GitHub token and sandboxed commands can't reach it. Claude asks before
  every push.
- Claude's own file tools run outside the sandbox and are governed by the permission
  rules in the same file.
- Adding a host or path to the sandbox is a change to a protected path, so it needs a
  CR.

## Consequences

- The account boundary protects personal data even from tools that run outside the
  sandbox.
- No container or virtual machine to build, maintain or explain.
- Windows developers need WSL2 for the sandbox.
- Each developer can loosen the shared settings with personal overrides; the template
  can't prevent that (see the threat model's known limitations).

## Alternatives considered

- **A dev container with a default-deny firewall.** Stronger isolation, but much more to
  build, verify and maintain. Built and reviewed under the first version of CR-0001,
  then parked on branch `cr/0001-dev-container`, tracked by a GitHub issue.
- **A virtual machine.** Stronger still, but heavier and harder for collaborators to
  reproduce.
- **No isolation.** Common, but not acceptable on a computer holding personal data.
