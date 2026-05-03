---
name: write-a-prd
description: Synthesizes the current conversation context into a structured PRD (Product Requirements Document). Use when user wants to create a PRD, formalize requirements, or capture a feature spec from the current conversation.
---

# Write a PRD

## Workflow

### 1. Load project context

Check for `PROJECT.md` at repo root:

```bash
cat PROJECT.md 2>/dev/null
```

If it exists, read the project goal and list of features/sub-goals. The PRD belongs to one of those features. Ask the user which feature this PRD is for (or infer from conversation context). If PROJECT.md does not exist, the PRD is standalone.

### 2. Extract from context

Scan the conversation for:
- Feature/problem being discussed
- Goals and motivations mentioned
- Constraints, requirements, edge cases stated
- Implicit acceptance criteria

### 3. Draft PRD using the template below

### 4. Present draft — show the user and wait for approval before publishing

### 5. Publish

Check how many `PRD-*.md` files already exist to determine the next index:

```bash
ls PRD-*.md 2>/dev/null | wc -l
```

Save to `PRD-<NNN>-<feature-name>.md` (zero-padded three-digit index, e.g. `PRD-001-auth.md`). Tell the user the file path and suggest running `/to-issues` next to break it into issues.

## PRD Template

<prd-template>
```markdown
# PRD: <feature name>

## Project
<!-- Link to PROJECT.md or state the parent project goal if PROJECT.md exists. Omit if standalone. -->

## Feature
<!-- Which feature/sub-goal of the project this PRD covers. Omit if standalone. -->

## Summary
[One paragraph: what are we building and why]

## Problem
[What pain or gap does this address]

## Goals
- [ ] 

## Non-goals
- Out of scope: 

## Requirements

### Must have
- 

### Nice to have
- 

## User Stories

A numbered list of user stories. Each in the format:

1. As a <actor>, I want <feature>, so that <benefit>

This list should be extensive and cover all aspects of the feature.

## Implementation decisions

- Modules to build/modify
- Interface changes
- Architectural decisions
- Schema changes
- API contracts

Do NOT include specific file paths or code snippets — they go stale.

## Acceptance criteria
- [ ] 

## Open questions
- 
```
</prd-template>