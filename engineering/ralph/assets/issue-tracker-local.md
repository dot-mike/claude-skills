# Issue tracker — local markdown

Issues live as markdown files under `docs/issues/`.

## Conventions

- One file per issue: `docs/issues/<slug>.md`
- Filename = slug (kebab-case, no spaces)
- Status tracked via frontmatter

## File template

```markdown
---
title: <title>
status: open   # open | in-progress | closed
labels: []
created: YYYY-MM-DD
---

## Problem
<description>

## Acceptance criteria
- [ ] 
```

## Workflow

- Create: write a new file
- Close: set `status: closed` in frontmatter
- Triage: add labels to frontmatter array