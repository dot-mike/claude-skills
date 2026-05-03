# Domain docs

## Layout

**single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root.

> If this is a monorepo, change layout to `multi-context` and add a `CONTEXT-MAP.md` at the root pointing to per-package `CONTEXT.md` files.

## Consumer rules for agents

- Read `CONTEXT.md` for domain language and project purpose before writing issues or PRDs
- Read `docs/adr/*.md` for past architectural decisions before proposing changes
- Do not contradict decisions recorded in ADRs without flagging the conflict to the user