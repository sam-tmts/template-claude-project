# ADR-0001: Change requests are markdown files in the repository

| Field      | Value                    |
|------------|--------------------------|
| Status     | Accepted                 |
| Date       | 2026-11-21               |
| Deciders   | Samuel Taylor (sam-tmts) |
| Related CR | CR-0000                  |

## Context

Every change is driven by a documented change request (CR). Much of the work is done by
coding agents, which work best from written specifications they can read, update and be
checked against.

## Decision

Each CR is a markdown file in `docs/cr/`, named `CR-NNNN-short-name.md` and based on
`docs/cr/CR-TEMPLATE.md`. It holds what doesn't change during the build: why, scope,
design notes, acceptance criteria (each saying how it's verified), constraints, and an
approval log recording each gate. The implementation plan is a working document: it is
agreed in plan mode and kept in the pull request description, not in the CR. A GitHub
issue may track a CR, but the file is the specification. Commits are titled
`CR-NNNN: <imperative summary>`, and every pull request links its CR. The one exception
is Dependabot's routine updates of already approved dependencies, which the owner
reviews and merges without a CR. Trivial changes (records, typos, documentation wording,
changelog moves; see `CLAUDE.md`) still link a CR, but skip the separate plan and
reviewer pass and use a short PR description.

## Consequences

- Agents can read the CR, the test-writer works from its acceptance criteria, and the
  reviewer checks diffs against it.
- Because the plan isn't in the CR, a build that differs from its plan only changes the
  CR when it changes the scope or the acceptance criteria.
- The history of every change, including its reasoning and approvals, is in the
  repository itself.
- CR numbers are allocated by hand; two CRs drafted at once must not take the same
  number.

## Alternatives considered

- **GitHub issues only.** Not versioned with the code, harder for agents to update
  reliably, and lost if the repository moves.
- **No formal CRs.** Faster for tiny changes, but loses the stage gates the owner wants
  while learning to work with agents.
