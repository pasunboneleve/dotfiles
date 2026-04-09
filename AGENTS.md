# AGENTS.md

> Optimise for systems that are easy to change, not just easy to run.

## Principles

- Prefer designs that reduce the cost of change.
- Prefer loose coupling over convenience reuse.
- Prefer local reasoning over hidden cross-system behaviour.
- Prefer simple textual interfaces between components over tightly coupled internal APIs.
- Keep architecture legible. If a change requires understanding internals across many modules, the abstraction is likely wrong.
- Favour explicitness over cleverness.
- Make the smallest change that preserves a clean direction.

## Defaults

- Start with the simplest working design that can be extended safely later.
- Prefer composition over inheritance.
- Prefer small modules with clear responsibilities.
- Keep public surfaces small and stable.
- Keep control flow easy to follow.
- Use helpers to remove duplication within a module when doing so does not introduce unnecessary coupling.
- Apply DRY carefully. Do not extract shared abstractions too early; duplication is often cheaper than the wrong abstraction.
- Write code that can be understood in isolation by a future maintainer.
- Keep tests close to behaviour and runnable in a local development workflow.
- When designing abstractions, optimise for ease of modification, not maximal reuse.

## Delivery rules

- Do not leave TODO comments, placeholder branches, or unfinished scaffolding behind.
- Do not expose internal exception details, stack traces, infrastructure errors, or sensitive implementation details in HTTP responses.
- Return clear and stable error responses externally; keep detailed diagnostics in logs or internal telemetry.
- Fail loudly on missing required configuration rather than silently inventing defaults unless the task explicitly requires safe defaults.
- Preserve existing user-facing behaviour unless the change intentionally updates it.
- Keep commits coherent and scoped to a single purpose where practical.

## Commit messages

- When creating a commit, write a message that explains both what changed and why.
- Include the key tradeoff or rejected alternative when it materially influenced the design.
- Prefer commit messages that help a reviewer understand the design choice, not just the file diff.
- Do not use vague commit messages such as "fix stuff", "updates", or "refactor".

## Smells to question

- A change requires touching many unrelated modules.
- An abstraction requires reading its implementation to use it safely.
- Shared helpers introduce hidden policy or couple unrelated layers.
- Error handling leaks transport, storage, or vendor-specific details across boundaries.
- A public API mirrors internal implementation details.
- A refactor increases indirection without making future change easier.
- Tests are difficult to run locally or depend on unrelated moving parts.
- Duplication was removed by creating an abstraction that is harder to change than the duplicated code.

## Review checklist

- Is this change making the system easier to change?
- Is coupling reduced, contained, or at least made explicit?
- Is any abstraction justified by actual reuse or stability needs?
- Are error boundaries clean?
- Are HTTP responses safe and intentional?
- Is there any unfinished placeholder work left behind?
- Would a new contributor be able to understand and modify this without reading half the codebase?
