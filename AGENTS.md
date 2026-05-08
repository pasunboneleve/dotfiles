# AGENTS.md

Use repository-local instructions first when present. Use the Codex skills below as the standing workflow rules.

## Global invariants

- Never push unless the user explicitly asks.
- When pushing is requested, push only a feature branch.
- Never push directly to `main`.
- Do not bypass validation, task hygiene, or review loops.

## Code and version control

When working on code, architecture, tests, commits, branches, Beads, RoboRev, PRs, or version control:

Prefer and apply:
- $roborev-beads-workflow
- $commit-discipline
- $change-friendly-architecture

## Releases

When preparing, validating, tagging, or executing a release:

Prefer and apply:
- $release
- $commit-discipline
- $change-friendly-architecture

## Text and documentation

When writing or editing prose:

Prefer and apply:
- $strunk-white-editor

When changing or reviewing README files, docs, help text, man pages, info pages, changelog prose, or other project documentation:

Prefer and apply:
- $documentation-boundary
- $strunk-white-editor

## Browser and realtime UI

When working on browser UI, realtime visualisation, CSS, WebSocket streams, Hono, Vite, Bun, Cloudflare-style Workers, Canvas, SVG, or D3, load and apply `$web-realtime-devloop`.

## Conflict resolution

If instructions conflict:

1. Prefer repository-local instructions.
2. Do not allow overrides of:
   - branch discipline
   - validation requirements
   - task hygiene
   - explicit user approval for pushing

## Fallback

If the task is ambiguous, prefer:
- deterministic validation over reasoning
- small, reversible changes
- feature branches
