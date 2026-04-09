# AGENTS.md

> Optimise for systems that are easy to change, not just easy to run.

## Execution rules (non-negotiable)

- Track work explicitly. Use a task system (e.g. bd). Do not leave TODO comments in code.
- Work is not complete until:
  - relevant checks pass (tests, linters, builds)
  - changes are committed
  - changes are pushed
- Never leave work stranded locally.
- Keep commits small, coherent, and reviewable.
- When creating commits, explain what changed and why. Include key tradeoffs when relevant.
- Do not expose internal errors, stack traces, or sensitive details in HTTP responses.
- Fail loudly on missing required configuration.
- Preserve existing user-visible behaviour unless intentionally changing it.

## Failure and observability

- Silent failure is unacceptable.
- Failures must be visible and diagnosable.
- Do not swallow errors without intent.
- Preserve useful failure context (logs, artifacts, summaries).
- Prefer loud, non-fatal failures when safe to continue.

## State and control flow

- Avoid hidden or ambient state.
- Pass meaningful state explicitly.
- Do not rely on implicit coupling through environment or shared globals.
- Prefer explicit signals over timing-based coordination (no "sleep" to fix races).

## Design defaults

- Start simple. Grow complexity only when demanded by real use cases.
- Prefer composition over inheritance.
- Prefer small modules with clear responsibilities.
- Use helpers within a module to reduce duplication.
- Apply DRY carefully. Do not introduce shared abstractions that increase coupling.
- Prefer explicit interfaces over convenience helpers across boundaries.

## Design principles

- Prefer systems that are cheap to change.
- Prefer decoupling over reuse.
- Prefer local reasoning over global coordination.
- Prefer textual interfaces over tightly coupled APIs.
- Keep architecture legible. If a change requires understanding internals across many modules, the abstraction is wrong.

## Smells to question

- A change requires touching many unrelated modules.
- An abstraction requires reading its implementation to use safely.
- Shared helpers introduce hidden coupling.
- Error handling leaks internal details across boundaries.
- A refactor increases indirection without making change easier.
- Tests are hard to run locally.
- Duplication was removed by introducing a worse abstraction.

## Review checklist

- Does this make the system easier to change?
- Is coupling reduced or made explicit?
- Is the abstraction justified by real use?
- Are failure paths visible and safe?
- Are external interfaces clean and intentional?
- Is there any unfinished work left behind?
