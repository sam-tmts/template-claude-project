# CR-0001: Dev container and streamlined workflow

| Field         | Value                                                       |
|---------------|-------------------------------------------------------------|
| Status        | Approved                                                    |
| Author        | sam-tmts (drafted with Claude)                              |
| Created       | 2026-11-21                                                  |
| Semver impact | minor: adds the dev container and a trivial-change workflow |

## Why

Coding agents should only ever run on a developer's computer inside a dev container: one
that can see the project folder and nothing else, and can reach only the network hosts
the work needs. That lifts CR-0000's interim rule against running Claude Code locally,
so projects can start. It is also recommended practice to work in a dedicated developer
account with no access to personal data, so that even the tools that run outside the
container can't reach it.

Separately, small record-keeping and wording fixes don't need the full plan and review
cycle. This CR defines a lighter path for them.

## Scope

### In: the dev container

- `.devcontainer/`: the container, its outbound firewall and its host allowlist,
  starting from the version reviewed on the `cr/0000-template-repository` branch,
  including the fixes from that review.
- `.githooks/pre-commit`: a gitleaks scan before every commit made inside the
  container. The container takes gitleaks from its official Docker image, pinned to an
  exact image build, so Dependabot proposes updates; Dependabot watches the container's
  images.
- ADR-0004: agents run in a dev container with a default-deny firewall.
- README: one-time setup on a developer's computer (a dedicated developer account,
  container runtime, VS Code settings), rules for working on the host, and how to
  verify the container; the interim "don't run Claude Code locally" note removed.
- Threat model, dependency register and test plan updated for the container.
- Claude Code's permission rules checked and tightened, since this is the first time
  Claude Code runs against these repositories.

### In: workflow

- **Trivial changes:** a rule in `CLAUDE.md` (what counts, what never counts, what it
  still needs), a line at the top of the PR template for the short description, and a
  sentence in ADR-0001.
- **Housekeeping:** `.github/scripts/` added to the protected paths in `CLAUDE.md`, and a
  threat-model entry for an agent working from Claude's cloud workspace with GitHub
  access (accepted for now, because the owner reviews every change).
- **Release criteria:** the template's release criteria in the test plan. A release may
  include work whose CR isn't Done, but its changelog entries are marked
  **experimental**, saying what isn't verified yet. A sentence in ADR-0002 to match.

### Out (each to a later CR)

- A separate GitHub account for the agent, so the owner can formally approve its pull
  requests. Tracked as a GitHub issue.
- A YAML-aware version of the CI check that actions are pinned and tokens read-only.
  Tracked as a GitHub issue.
- Updating gitleaks in CI, which is still pinned by hand. Tracked as a GitHub issue.
- Language toolchains: each project's first CR.

## Design notes

Based on Anthropic's reference dev container, pinned to a recorded upstream commit, with
every difference listed in the file headers. The firewall applies its deny policy before
anything else, so if setup fails part-way the container is left with no outbound access
rather than full access. It allows HTTPS only, to GitHub's published address ranges and
to a root-owned allowlist the container can't change. IPv6 is blocked. Only the project
folder is mounted; host SSH-agent and git-credential sharing are switched off.

VS Code is supported, attached to the container through its Dev Containers feature.
Extensions, including Claude Code's, are downloaded on the host and copied into the
container (`remote.downloadExtensionsLocally`), pinned to a version, with auto-update
off, so the container never contacts the extension marketplace. If that doesn't work,
the fallback is to allow the three Microsoft extension hosts and record the risk in the
threat model and ADR-0004: they sit on shared delivery networks, so allowing their
addresses also reaches other sites on the same addresses. HTTPS-only traffic, no
sensitive data in the container, a root-owned allowlist and owner review of every change
limit the damage.

The allowlist includes `claude.ai` and `console.anthropic.com` for signing in to Claude
Code; either is removed if AC6's check shows it isn't needed.

ADRs created: ADR-0004 (dev container with a default-deny firewall). Relies on: ADR-0001,
ADR-0003.

## Acceptance criteria

- [ ] AC1: If firewall setup fails at any step, the container has no outbound access
      apart from DNS to its own resolver.
      *Verified by:* manual check M5 (break the allowlist on purpose, restart, try an
      allowed host).
- [ ] AC2: From inside the container, `example.com` is unreachable; GitHub and the
      Anthropic API are reachable over HTTPS; other ports on allowed hosts (for example
      SSH to GitHub) are not.
      *Verified by:* manual check M6.
- [ ] AC3: The container can't see any host folder except the project folder, the host's
      SSH agent, the host's git credentials, or VS Code's git sign-in passthrough.
      *Verified by:* manual check M7.
- [ ] AC4: Claude Code inside the container refuses to read `.env` files (directly and
      with `cat`), to force-push and to merge a pull request, and asks before editing a
      protected path.
      *Verified by:* manual check M8.
- [ ] AC5: A commit made inside the container that contains a fake secret is blocked by
      the pre-commit hook.
      *Verified by:* manual check M9.
- [ ] AC6: Claude Code can be signed in and complete a simple request from inside the
      container, with only the hosts on the allowlist.
      *Verified by:* manual check M10.
- [ ] AC7: The trivial-change rule is in `CLAUDE.md`, the PR template and ADR-0001, and
      a trivial change goes through it.
      *Verified by:* this CR's closing PR uses it.
- [ ] AC8: The release criteria in the test plan and ADR-0002 say that unfinished work
      may be released only when its changelog entries are marked experimental.
      *Verified by:* this CR's release follows them.
- [ ] AC9: The Claude Code extension installs and works in VS Code attached to the
      container, and the allowlist in use is the one recorded in the threat model
      (without the Microsoft extension hosts, unless the fallback was needed).
      *Verified by:* manual check M11.

## Constraints and risks

- Claude Code is first started inside the container only after AC1 to AC3 pass. For
  this CR, those checks run in the owner's dedicated developer account on a Mac.
- The only credentials inside the container are Claude Code's sign-in and a fine-grained
  GitHub token for one repository, with a short expiry.
- The firewall can't be tested from Claude's cloud workspace, so AC1 to AC6 are checked
  by the owner on the Mac.
- Windows collaborators: the container should behave the same under Docker Desktop on
  Windows, but there's no Windows machine to check it on yet.

## Approval log

| Gate | Date | By | Notes |
|------|------|----|-------|
| CR approved | 2026-11-21 | Sam (sam-tmts) | |
| Plan approved | 2026-11-21 | Sam (sam-tmts) | Plan in the PR description |
| PR merged | | | |
| Released | | | |
