# Threat model

What we protect, where the trust boundaries are, the threats we expect, and how each is
mitigated. Update it in the same pull request as any change that affects these.

> **Template note.** This version covers only what every project shares. CR-0001 adds
> the dev container that contains coding agents; each project adds the assets,
> boundaries and threats of its own software.

## Assets

| Asset | Why it matters |
|-------|----------------|
| Owner's personal and family data on their computer | Highly sensitive; must never be reachable by an agent |
| Credentials (API keys, OAuth tokens, SSH keys, GitHub tokens) | Misuse could expose accounts or data |
| Integrity of the repository and its `main` branch | Others may build on this code |
| The owner's GitHub account | Controls all repositories, not just this one |

## Trust boundaries

1. **Owner ↔ agent.** The agent proposes; the owner approves at each stage gate (see
   `CLAUDE.md`).
2. **Branch ↔ `main`.** Changes reach `main` only through a pull request, after CI has
   run. The owner merges. Pull requests are currently pushed through the owner's own
   account, so GitHub can't require a separate approval.

## Threats and mitigations

| Threat | Mitigations | Residual risk |
|--------|-------------|---------------|
| **Agent reaches personal data** on the owner's computer | Until CR-0001's dev container lands, agents are not run on the owner's computer against these repositories | None while that rule holds |
| **Secrets committed by mistake** | ADR-0003; gitleaks in CI; GitHub secret scanning and push protection | A secret in a format no scanner recognises |
| **Malicious or typo-squatted dependency** | Approval required for every new dependency, recorded in `docs/dependencies.md`; pinned versions; Dependabot alerts | A compromised version of an approved dependency |
| **Compromised GitHub Action** | Third-party actions pinned to full commit SHAs (checked in CI); default workflow token read-only; fork PR workflows need owner approval | A compromised action at the pinned commit |
| **Unreviewed change reaches `main`** | Ruleset requires a pull request and blocks force-push and deletion of `main`; Claude Code denies merging and asks before pushing | With no required approval, anyone with write access can merge. A separate agent account with required owner approval is planned |
