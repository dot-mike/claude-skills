---
name: to-issues
description: Breaks a PRD, plan, or spec into independently-grabbable vertical-slice issues and publishes them to the project issue tracker. Use when user wants to convert a PRD into issues, create implementation tickets, or break down a feature into trackable work items. Run ralph first if issue tracker config is missing.
---

# To Issues

Break a PRD or plan into independently-grabbable issues using vertical slices (tracer bullets).

Issue tracker and triage label vocabulary come from `docs/agents/issue-tracker.md` and `docs/agents/triage-labels.md` — run `/ralph` if those files are missing.

## Process

### 1. Load context

Read from conversation or accept an argument (file path, issue URL/number, or PRD content directly):

- If a PRD file is referenced, read it
- If an issue number/URL is passed, fetch it from the tracker
- Otherwise work from conversation context

Also read:
- `docs/agents/issue-tracker.md` and `docs/agents/triage-labels.md` if present
- `PROJECT.md` if present — understand which feature/sub-goal this PRD belongs to and the overall project goal

### 2. Resolve feature context

If PROJECT.md exists and the PRD references a feature/sub-goal:

- Check if a feature tracker issue already exists for this sub-goal (`gh issue list --search "<feature name>" --label feature-tracker`)
- If not, create one (see Feature tracker template below) — this becomes the parent for all slice issues
- If yes, note its issue number

If no PROJECT.md, proceed without a feature tracker.

### 3. Explore codebase (optional)

Quick scan to understand current state so issue language matches the project's domain vocabulary and respects existing architecture.

### 4. Draft vertical slices

Break the plan into **tracer bullet** issues. Each is a thin vertical slice through ALL integration layers — NOT a horizontal layer slice.

Classify each slice:

- **AFK** — can be implemented and merged without human interaction (prefer these)
- **HITL** — requires human decision, design review, or approval before proceeding

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests as appropriate)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- No slice should depend on an unapproved architectural decision
</vertical-slice-rules>

### 5. Quiz the user

Present the proposed breakdown as a numbered list. For each slice show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices must complete first (if any)
- **User stories covered**: from the PRD (if applicable)

Ask:

- Does the granularity feel right? (too coarse / too fine)
- Are dependency relationships correct?
- Should any slices be merged or split?
- Are HITL/AFK assignments correct?

Iterate until approved.

### 6. Publish issues

Assign each slice a zero-padded index before publishing (001, 002, 003…). Use this number as the filename prefix: `001-core-solver.md`. Publish in dependency order (blockers first) so you can reference real numbers in "Blocked by".

For each approved slice, create an issue using the slice template below. Use the `needs-triage` label (or equivalent from triage-labels doc).

Do NOT modify or close the source PRD issue.

### 7. Print summary

After all issues are published, print a markdown table — not a file tree or list:

| # | File | Title | Blocked by |
|---|---|---|---|
| 001 | 001-core-solver.md | Core Solver | — |
| 002 | 002-validation-errors.md | Validation Errors | 001 |
| 003 | 003-test-suite.md | Test Suite | 002 |

Then print the run command on a single line (e.g. `bash scripts/afk.sh <n>`).

---

## Feature tracker template

Create this first (before slices) when a project sub-goal needs a parent issue:

```
gh issue create \
  --title "<feature name>" \
  --label "feature-tracker" \
  --body "..."
```

<feature-tracker-template>
```markdown
## Project goal
<link to PROJECT.md or state the goal>

## Feature / sub-goal
<which sub-goal of the project this tracks>

## PRD
<link to PRD file or issue>

## Scope
<one paragraph: what done looks like for this feature>

## Child issues
<!-- to-issues will populate this list as slices are created -->
```
</feature-tracker-template>

Create the `feature-tracker` label if missing:

```bash
gh label create feature-tracker --color "#0075ca" --description "Tracks all issues for a project feature" 2>/dev/null || true
```

---

## Slice issue template

<issue-template>
```markdown
## Project goal
<link to PROJECT.md goal or one-liner. Omit if standalone.>

## Feature
<which feature/sub-goal. Link to feature tracker issue. Omit if standalone.>

## Parent PRD
Link to the parent PRD issue or file (omit if no parent exists).

## What to build

Concise description of this vertical slice — end-to-end behavior, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- #<issue> — brief reason

Or: "None — can start immediately"
```
</issue-template>