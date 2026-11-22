# CR-0001: Principles, sandboxed development and streamlined workflow

| Field         | Value                                                         |
|---------------|---------------------------------------------------------------|
| Status        | Done                                                          |
| Author        | sam-tmts (drafted with Claude)                                |
| Created       | 2026-11-21                                                    |
| Semver impact | minor: enables local agentic development and workflow rules   |

## Why

Developers should be able to run Claude Code on their own computer without risking
their personal data. The simplest effective setup is a dedicated developer account with
no access to personal data, plus Claude Code's built-in sandbox, which limits what the
agent's shell commands can read, write and reach on the network. This lifts CR-0000's
interim rule against running Claude Code locally, so projects can start.

The work so far also showed the need for shared principles, in priority order, that keep
the template and everything built from it simple, enjoyable to use and proportionately
secure, and for the agent to challenge complexity before building it. Separately, small
record-keeping and wording fixes don't need the full plan and review cycle, and
releases need clear criteria.

## Scope

### In: sandboxed development

- Claude Code's sandbox switched on in `.claude/settings.json`, in strict mode: shell
  commands can write only to the project folder, can't read the rest of the account,
  can reach only allowlisted hosts, can't be retried outside the sandbox, and Claude
  Code won't start if the sandbox can't.
- Permission rules for Claude's file tools, which run outside the sandbox: no reading
  credential files, no force-push or merging (carried over from the container work).
- README: one-time setup (dedicated developer account, Claude Code), and how to check
  the sandbox; the interim "don't run Claude Code locally" note removed.
- ADR-0004: agents run in Claude Code's sandbox, in a dedicated developer account.
- SECURITY.md, threat model and test plan updated.

### In: principles and workflow

- A "Principles" section at the start of `CLAUDE.md`, above Workflow, word for word:

  > In priority order: when two conflict, the higher one wins.
  >
  > 1. **Elegance through Simplicity.** Choose the simplest design that meets the need.
  >    Every file, rule, check and dependency must earn its place; if something can go
  >    without losing what matters, remove it. Fix problems the simplest way, and prefer
  >    removing complexity to adding it.
  > 2. **Easy to use, fun to use.** Always ask what will be easiest and most enjoyable
  >    for the user: the people using what we build, developers using this template,
  >    and the owner working through its gates. Fewer features that work obviously beat
  >    more that need explaining.
  > 3. **Security in proportion to risk.** Build with security in mind at all times.
  >    Understand the risks, mitigate what you can simply, and be upfront about the
  >    rest: record each accepted risk in the threat model and, where users need to
  >    know, state it as a known limitation. Only the owner accepts a risk. If a
  >    mitigation would add complexity out of proportion to the risk, stop and document
  >    it instead.
  > 4. **Learn from others, keep improving.** Start from established good practice
  >    rather than inventing our own, and depart from it only for a stated reason.
  >    After each release, look back briefly at what worked and what to change.
  > 5. **Document clearly and concisely.** Write for the reader, in the fewest words
  >    that do the job. Keep each fact in one place and link to it rather than
  >    repeating it.
  > 6. **Automate what repeats.** When a task recurs, automate it if that is simpler and
  >    more reliable than doing it by hand. One-off tasks stay manual.

- A working rule in `CLAUDE.md`'s Workflow, word for word:

  > **Challenge before building.** If a design adds significant complexity, or departs
  > from common good practice, say so before building it: name the simpler or more
  > common alternative, and let the owner decide.

- The reviewer's checks follow the principles, in order: simplicity, ease of use,
  security, established practice, clear documentation, automation. It weighs every
  finding against the risk, and doesn't escalate minor issues to blockers.
- Existing documentation trimmed so each fact lives in one place: duplication between
  the README, test plan, threat model and ADRs replaced by links.
- Trivial-change rule in `CLAUDE.md`, a note in the PR template, a sentence in ADR-0001.
- Release criteria in the test plan, with experimental entries allowed (ADR-0002), and
  a short retrospective before each release, recorded in `docs/retrospectives.md` (what
  worked, what to change, what changed as a result).
- `.github/scripts/` added to the protected paths; a threat-model entry for an agent
  working from Claude's cloud workspace with GitHub access.

### Out

- Python support for the template (uv, test and lint tools, a single "run everything"
  command): CR-0002.
- Each of these is tracked as a GitHub issue:
  - containerised development (parked on branch `cr/0001-dev-container`);
  - a separate GitHub account for the agent;
  - a YAML-aware pinning check;
  - automating gitleaks updates in CI;
  - testing the template on Windows (VM).
- Other language toolchains: each project's first CR.

## Design notes

On macOS the sandbox uses the operating system's Seatbelt framework, so it needs no
extra software. It wraps the shell commands Claude runs and everything they start;
Claude's file tools, hooks and any MCP servers run outside it and are governed by
permission rules instead. The network allowlist works through a local proxy and starts
with GitHub only; projects add their own hosts. The dedicated developer account is the
main protection for personal data: even something that runs outside the sandbox finds
nothing personal to reach.

ADRs created: ADR-0004 (sandboxed development in a dedicated developer account).
Relies on: ADR-0001, ADR-0003.

## Acceptance criteria

- [x] AC1: A shell command Claude runs can't reach a host outside the allowlist.
      *Verified by:* manual check M5.
- [x] AC2: A shell command Claude runs can't write outside the project folder, or read
      the account's credential files (for example `~/.ssh`).
      *Verified by:* manual check M6.
- [x] AC3: Strict mode holds: Claude can't retry a command outside the sandbox, and
      Claude Code won't run commands if the sandbox can't start.
      *Verified by:* manual check M7.
- [x] AC4: Claude's file tools refuse to read `.env` and credential files, and Claude
      Code blocks force-pushing and merging, each by a permission rule.
      *Verified by:* manual check M8.
- [x] AC5: Day-to-day work still flows: Claude can edit files, run git commands and the
      project's tools, and a push goes through the normal approval.
      *Verified by:* manual check M9.
- [x] AC6: `CLAUDE.md` opens with the six principles and contains the "Challenge
      before building" rule, both word for word as in this CR, and the reviewer's
      checks follow the principles in order.
      *Verified by:* this CR's independent review, which uses the new checks.
- [x] AC7: The trivial-change rule is in `CLAUDE.md`, the PR template and ADR-0001.
      *Verified by:* this CR's closing PR uses it.
- [x] AC8: The release criteria allow unfinished work only when its changelog entries
      are marked experimental, and require a retrospective entry before each release.
      *Verified by:* this CR's release follows them, with the first entry in
      `docs/retrospectives.md`.
- [x] AC9: No fact about the template's setup, workflow or security is stated in more
      than one document; repeats are replaced by links.
      *Verified by:* the reviewer's documentation check.

## Constraints and risks

- The sandbox isn't a complete boundary: file tools, hooks and MCP servers run outside
  it. The developer account having no personal data is what makes that acceptable.
- Credentials kept in the developer account (for example a GitHub token) are readable
  by Claude's file tools unless a permission rule denies them.
- Windows collaborators need WSL2 for the sandbox.
- How git pushes get their credentials from inside the sandbox is settled during the
  build; a push may need to run outside the sandbox, with approval.

## Approval log

| Gate | Date | By | Notes |
|------|------|----|-------|
| CR approved | 2026-11-22 | Sam (sam-tmts) | Replaces the dev container version approved on 2026-11-21 |
| Plan approved | 2026-11-22 | Sam (sam-tmts) | Plan in the PR description |
| PR merged | 2026-11-22 | Sam (sam-tmts) | PR #6. AC1–AC5 verified on the Mac (M5–M9); M8 and M9 found two settings bugs, fixed before merge. AC6 accepted by the owner; AC9 by the review |
| Released | 2026-11-22 | Sam (sam-tmts) | v0.2.0, tagged on this closing PR's merge; AC7 shown by this trivial-change PR, AC8 by the release and the first retrospective |
