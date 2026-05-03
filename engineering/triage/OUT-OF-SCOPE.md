# Out-of-Scope Knowledge Base

`.out-of-scope/` in a repo stores persistent records of rejected feature requests.

**Purposes:**
1. **Institutional memory** — why a feature was rejected, so reasoning isn't lost when the issue closes
2. **Deduplication** — surface prior rejections instead of re-litigating them

## Directory structure

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

One file per **concept**, not per issue. Multiple issues requesting the same thing are grouped under one file.

## File format

```markdown
# Concept Name

Short explanation of what was rejected.

## Why this is out of scope

Substantive reasoning — project scope, technical constraints, or strategic decisions.
Reference interfaces or architecture where helpful.

## Prior requests

- #42 — "Issue title"
- #87 — "Issue title"
```

### Naming

Short kebab-case concept name: `dark-mode.md`, `plugin-system.md`. Recognizable without opening the file.

### Writing the reason

Reference:
- Project scope or philosophy
- Technical constraints
- Strategic decisions

Avoid temporary circumstances ("too busy") — those are deferrals, not rejections.

## When to check `.out-of-scope/`

At Step 1 (Gather context) of every triage session. Read all files. Match by concept similarity, not keyword — "night theme" matches `dark-mode.md`.

If there's a match, surface it: "This is similar to `.out-of-scope/dark-mode.md` — rejected before because [reason]. Still feel the same way?"

The maintainer may:
- **Confirm** — append issue to existing file's "Prior requests", close
- **Reconsider** — delete or update the file, proceed with normal triage
- **Disagree** — issues are distinct, proceed with normal triage

## When to write to `.out-of-scope/`

Only when an **enhancement** (not a bug) is rejected as `wontfix`:

1. Maintainer decides feature request is out of scope
2. Check if a matching file already exists
3. If yes: append to "Prior requests"
4. If no: create new file with concept name, decision, reason, and first prior request
5. Post a comment explaining the decision, mentioning the file
6. Close with `wontfix` label

## Updating or removing

If the maintainer changes their mind: delete the file. Old issues are historical records — don't reopen them. New issue proceeds through normal triage.