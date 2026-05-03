---
name: zoom-out
description: Zoom out from an unfamiliar section of code to get a higher-level map of modules, callers, and domain context. Use when you don't know an area well, need to understand how a piece fits the bigger picture, or want a domain-vocabulary-aware orientation. Requires ralph setup (CONTEXT.md + docs/agents/domain.md) for full context.
---

# Zoom Out

Zoom out from an unfamiliar section of code to get a higher-level view.

## Steps

1. Read domain context if present:
   ```bash
   cat CONTEXT.md 2>/dev/null
   cat docs/agents/domain.md 2>/dev/null
   cat docs/adr/*.md 2>/dev/null
   ```

2. Go up a layer of abstraction from the current file/function. Map:
   - All callers and entry points
   - Sibling modules at the same layer
   - The layer above (what orchestrates this?)
   - Key data flows in and out

3. Use domain vocabulary from CONTEXT.md. If no CONTEXT.md exists, suggest running `/ralph` first.

4. Present as a module map, not prose — names, arrows, one-line roles. Flag any ADR conflicts with proposed changes.

> If ralph hasn't been run: `CONTEXT.md` missing — domain terms may be imprecise. Run `/ralph` to scaffold context.