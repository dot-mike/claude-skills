---
name: improve-codebase-architecture
description: Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and past decisions in docs/adr/. Use when the user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more testable and AI-navigable. Reads issue tracker config from the ## Agent skills block in CLAUDE.md/AGENTS.md (set up by ralph).
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Glossary

Use these terms exactly in every suggestion. Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place.
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth.

Key principles (see [LANGUAGE.md](LANGUAGE.md)):

- **Deletion test**: if deleting the module makes complexity vanish, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

## Ralph context

Before exploring the codebase, read the `## Agent skills` block in `CLAUDE.md` or `AGENTS.md`:

```bash
grep -A 20 "## Agent skills" CLAUDE.md AGENTS.md 2>/dev/null
```

This gives you:
- **Issue tracker** — where to file issues for candidates the user wants to queue (not act on immediately)
- **Triage labels** — vocabulary for labelling those issues
- **Domain docs layout** — single-context (`CONTEXT.md` + `docs/adr/`) or multi-context (`CONTEXT-MAP.md`)

If ralph hasn't been run, tell the user: _"Run `/ralph` first so I have issue tracker and domain doc context."_

## Process

### 1. Explore

Read domain glossary and any ADRs first:

```bash
cat CONTEXT.md 2>/dev/null
ls docs/adr/ 2>/dev/null && cat docs/adr/*.md 2>/dev/null
```

Then spawn an Explore subagent to walk the codebase organically. Note friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted for testability, but the real bugs hide in how they're called?
- Where do tightly-coupled modules leak across their seams?
- Which parts are untested or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow.

### 2. Present candidates

Present a numbered list. For each:

- **Files** — which files/modules are involved
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — in terms of locality, leverage, and how tests would improve

**Use CONTEXT.md vocabulary for domain, [LANGUAGE.md](LANGUAGE.md) vocabulary for architecture.**

**ADR conflicts**: only surface a candidate that contradicts an ADR when friction is real enough to warrant revisiting it. Mark it clearly (_"contradicts ADR-0007 — but worth reopening because…"_).

Ask the user: _"Which of these would you like to explore?"_

Do NOT propose interfaces yet.

### 3. Grilling loop

Drop into a grilling conversation for the chosen candidate. Walk the design tree: constraints, dependencies, shape of the deepened module, what sits behind the seam, what tests survive.

Side effects as decisions crystallize:

- **New concept not in CONTEXT.md?** Add the term now — same discipline as `/grill-me`. Create CONTEXT.md lazily if absent.
- **Fuzzy term sharpened?** Update CONTEXT.md immediately.
- **User rejects with a load-bearing reason?** Offer an ADR: _"Want me to record this as an ADR so future reviews don't re-suggest it?"_ Only offer when the reason would matter to a future explorer — skip ephemeral reasons.
- **User wants to queue candidate as an issue instead of exploring now?** Use the issue tracker from `docs/agents/issue-tracker.md` and the label `ready-for-agent` or `needs-triage` per `docs/agents/triage-labels.md`.
- **Exploring alternative interfaces?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).