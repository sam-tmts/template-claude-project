# Retrospectives

A short look back before each release (see the release criteria in
[test-plan.md](test-plan.md)): what worked, what to change, and what changed as a
result. A lesson that keeps coming up becomes an update to `CLAUDE.md`.

## 0.2.0 — 2026-11-22

### What worked

- The gates caught real problems before they reached `main`: independent reviews found
  a firewall that failed open and a check that could pass falsely.
- Testing on the real Mac found two bugs no review could (the `.git` rule blocking
  commits, and pushes needing credentials outside the sandbox).
- Pushing back on complexity, once we started doing it, quickly led to simpler designs.

### What to change

- Try the simplest well-trodden option before building anything bespoke: we built and
  reviewed a dev container before testing Claude Code's own sandbox.
- Weigh review findings against the risk instead of fixing every one.
- Test on the real machine earlier, and phrase manual checks plainly.

### What changed as a result

- Principles at the top of `CLAUDE.md`, a challenge-before-building rule, and reviewer
  checks that follow the principles.
- CRs hold intent and acceptance criteria; the plan lives in the pull request.
- The container parked in favour of the sandbox in a dedicated developer account.
- A lighter path for trivial changes, and a retrospective before each release.
