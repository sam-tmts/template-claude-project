# Threat model

What we protect, where the trust boundaries are, the threats we expect, and how each is
mitigated. Update it in the same pull request as any change that affects these.

> **Template note.** This version covers the development environment every project
> inherits. Each project adds the assets, boundaries and threats of its own software
> (for example, how it stores tokens or what it exposes on a network).

## Assets

| Asset | Why it matters |
|-------|----------------|
| Personal data on the developer's computer | Highly sensitive; must never be reachable by an agent |
| Credentials (API keys, OAuth tokens, SSH keys, GitHub tokens) | Misuse could expose accounts or data |
| Integrity of the repository and its `main` branch | Others may build on this code |
| The owner's GitHub account | Controls all repositories, not just this one |

## Trust boundaries

1. **Host account ↔ personal data.** Development uses a dedicated developer account on
   the host with no access to personal data (recommended in the README), so even tools
   that run outside the container can't reach it.
2. **Host ↔ dev container.** Only the project folder crosses it, in both directions:
   files the container writes there can later be read or run on the host (see "Code run
   on the host"). The container has no access to the rest of the host's file system,
   its credential store, its SSH agent, its git credentials or VS Code's git sign-in.
3. **Dev container ↔ internet.** Outbound traffic is denied by default. Allowed: HTTPS
   (TCP 443) to GitHub's published address ranges and to the addresses of the hosts in
   `.devcontainer/allowed-domains.txt`, and DNS to the container's own resolver.
4. **Branch ↔ `main`.** Changes reach `main` only through a pull request whose required
   CI checks have passed. The owner merges. Pull requests are currently pushed through
   the owner's own account, so GitHub can't require a separate approval.
5. **Owner ↔ agent.** The agent proposes; the owner approves at each stage gate (see
   `CLAUDE.md`). This applies equally to an agent in the dev container and to an agent
   working from Claude's cloud workspace with access to the GitHub repository.

## Threats and mitigations

| Threat | Mitigations | Residual risk |
|--------|-------------|---------------|
| **Agent reaches personal data** | Agents run only in the dev container (ADR-0004), from a dedicated developer account with no personal data | Container escape (below) |
| **Prompt injection:** an agent reads untrusted text (web page, issue, pull request text, package docs) that tells it to do something harmful | Container boundary; outbound allowlist; `CLAUDE.md` rule to treat such text as data; owner review at every gate | An injected change could reach a pull request. Owner review of every diff is the backstop |
| **Code run on the host:** the container writes files in the shared folder that the host later runs, such as `initializeCommand` in `devcontainer.json`, `.vscode/tasks.json`, or git hooks and settings in `.git/` | Claude Code asks before editing `.devcontainer/`, `.vscode/`, `.githooks/`, `.github/` and `.claude/`, and is denied edits to `.git/`; `.vscode/` is not git-ignored, so changes show in review; the container's hook path is set in its own git config; the README's rules for working on the host; the developer account limits what host-side code could reach | A command run through the shell can still write these files. This is the most realistic route out of the container, so the host rules matter |
| **Data exfiltration** from the container | Default-deny firewall applied before anything else, so it fails closed; HTTPS only; DNS only to the container's resolver; IPv6 blocked; no extension marketplace access | Data could be sent to an allowed service (for example a GitHub gist), to an unrelated site sharing an allowed host's address, or encoded in DNS lookups. Keep the allowlist short; keep sensitive data out of the container |
| **Credential theft** | Real secrets never enter the repository or the container (ADR-0003); no host credential, SSH-agent or VS Code git sign-in passthrough; Claude Code `Read` deny rules for secret file patterns | Two credentials do live in the container: Claude Code's sign-in and the fine-grained GitHub token (stored in plain text by `gh`). Anything running in the container can read them. Keep the GitHub token to one repository, minimum permissions, short expiry |
| **Secrets committed by mistake** | gitleaks before every commit in the container (catches mistakes; anything in the container can bypass it); GitHub push protection; gitleaks in CI as a required check; GitHub secret scanning | The repository is public: a secret that push protection doesn't recognise is public as soon as it's pushed, even if CI then stops it reaching `main` |
| **Malicious or typo-squatted dependency** | Approval required for every new dependency, recorded in `docs/dependencies.md`; pinned versions, digests and checksums; Dependabot; the container limits the damage | A compromised version of an approved dependency |
| **Compromised GitHub Action** | Third-party actions pinned to full commit SHAs (checked in CI); default workflow token read-only; fork PR workflows need owner approval | A compromised action at the pinned commit |
| **Unreviewed change reaches `main`** | Ruleset requires a pull request and passing checks, and blocks force-push and deletion of `main`; Claude Code denies merging and asks before pushing; the container's token has no Workflows or Administration permission | With no required approval, anyone with write access can merge, including through the API. Accepted for now because the owner reviews every change; a separate agent account is on the backlog |
| **Destructive agent mistake** (deleting files, rewriting history) | The container limits reach to the project folder; Claude Code deny rules for force-push, rebase, amend and branch deletion; the ruleset protects `main`; everything is in git | Uncommitted work in the project folder could be lost |
| **Container escape** | Non-root user; sudo limited to running the firewall script with no arguments; the runtime runs containers inside a lightweight VM on macOS; the developer account limits what an escape could reach | Kernel or runtime vulnerabilities. Keep the container runtime updated |

## Known limitations

- Claude Code's permission rules are a guardrail, not a sandbox: they cover Claude's own
  file tools and the shell commands it recognises, but not the same program run another
  way, or a script that opens files itself. The container is the real boundary.
- The firewall allows IP addresses, not hostnames. A host behind a shared content
  delivery network shares its addresses with unrelated sites, which are then reachable
  too.
- Allowed hostnames are resolved when the container starts. If a service changes its
  addresses, restart the container.
- The host settings that stop VS Code sharing git credentials, and that download
  extensions on the host, are per user and per machine; the repository can't enforce
  them. Every developer must set them, and `verify-container.sh` checks the result.
