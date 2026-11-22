# ADR-0002: Semantic versioning with Keep a Changelog

| Field      | Value                    |
|------------|--------------------------|
| Status     | Accepted                 |
| Date       | 2026-11-21               |
| Deciders   | Samuel Taylor (sam-tmts) |
| Related CR | CR-0000                  |

## Context

Projects started from this template may be used by others, so releases need predictable
version numbers and a readable record of what changed.

## Decision

- Versions follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).
- Each project keeps its version in exactly one place (for example `pyproject.toml` or
  `package.json`), set in its first CR.
- Every CR states its semver impact, and every pull request adds its entries under
  `Unreleased` in `CHANGELOG.md`, in [Keep a Changelog](https://keepachangelog.com/)
  format.
- A release moves the `Unreleased` entries under a version heading, and is marked by a
  `vX.Y.Z` git tag.
- A release may include work whose CR isn't Done, but each such changelog entry is
  marked **experimental**, saying what isn't verified yet (see the release criteria in
  `docs/test-plan.md`).
- Projects stay at `0.x` until their public interface settles.

## Consequences

- Anyone can see what changed between versions without reading commits.
- Breaking changes are visible in the version number from `1.0.0` onwards.
- Each pull request carries a small amount of extra bookkeeping.

## Alternatives considered

- **Changelog generated from commit messages** (Conventional Commits). Less manual
  work, but commit messages are written for reviewers, not users; rejected in favour of
  the `CR-NNNN:` commit convention.
- **Date-based versions.** Simple, but say nothing about compatibility.
