# Issues

Issues JSON is provided at the start of context. Parse it to get open issues with their bodies and comments.

# Recent work

You've also been passed the last 10 commits (SHA, date, full message). Review these to understand what work has been done and avoid duplicating it.

# Task selection

Pick the next task. Prioritize in this order:

1. Critical bugfixes
2. Tracer bullets for new features
3. Polish and quick wins
4. Refactors

**Tracer bullets** (The Pragmatic Programmer): build a tiny end-to-end slice of a feature first — something that touches all layers — before expanding. This validates architecture early and surfaces issues before significant time is invested.

If all issues are closed, output `<promise>COMPLETE</promise>`.

# Exploration

Explore the repo and load relevant files into context before writing any code. Understand existing patterns before introducing new ones.

# Execution

Complete the task. Work on ONE task only — do not pick up additional tasks mid-iteration.

# Commit

Make a git commit. The message must include:

1. A short subject line with task type prefix (`FIX:`, `FEAT:`, `REFACTOR:`, `CHORE:`)
2. Issue reference (e.g. `closes #12`)
3. Key decisions made
4. Files changed
5. Any blockers or notes for the next iteration

# The issue

If the task is complete: close the original GitHub issue with `gh issue close <number> --comment "<summary>"`.

If the task is NOT complete: leave a comment on the issue with what was done and what remains.

# Rules

ONLY WORK ON A SINGLE TASK PER ITERATION.
