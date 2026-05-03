---
name: ralph
description: Prepares a repo for AFK agent-driven development. Sets up PROJECT.md (goal + features), PROMPT.md (agent methodology), docs/agents/ (issue tracker + triage labels + domain), deploys afk.sh/once.sh scripts, and wires the ## Agent skills block in CLAUDE.md. Run this before write-a-prd, to-issues, triage, diagnose, tdd, or zoom-out — or whenever those skills seem to be missing repo context.
---

# Ralph — Repo Agent Layout Prep Helper

Scaffold per-repo config that engineering skills assume. Prompt-driven, not a script — explore first, then confirm, then write.

## Process

### 0. Git check

Before anything else, verify the working directory is a git repo:

```bash
git rev-parse --git-dir 2>/dev/null
```

If the command fails (not a git repo), **stop and tell the user**:

> This directory is not a git repository. Run `git init` to create one (no remote needed), then re-run ralph.

Do not proceed past this point until the user has a git repo.

### 1. Explore

Read the repo before asking anything:


```bash
git remote -v                          # GitHub? GitLab?
ls AGENTS.md CLAUDE.md 2>/dev/null    # which file exists?
grep -n "## Agent skills" CLAUDE.md AGENTS.md 2>/dev/null  # already set up?
ls docs/agents/ 2>/dev/null           # prior ralph output?
ls docs/adr/ CONTEXT.md 2>/dev/null   # domain docs layout?
gh label list 2>/dev/null             # existing labels?
```

### 2. Interview — one section at a time

Present findings, then ask these four sections one at a time. Don't dump all at once.

**A — Project goal and sub-goals** *(skip if no AFK mode planned)*

Is the user building a specific project with afk.sh, or just wiring up skills for ad-hoc use?

If project-mode:
- Project name and one-paragraph goal
- List of sub-goals in the order they should be tackled — each one is a unit of work one AFK session can complete (e.g. Setup, Backend, Frontend, Testing, Docs)
- Hard constraints the agent must respect throughout (language, frameworks, no-push rule, etc.)

Sub-goals must be concrete enough that an agent can decide when it's done. Push back on vague ones ("Backend" alone is too vague — ask what the backend needs to do).

**B — Issue tracker**

Where does work live? Default to GitHub if remote points there.

- **GitHub** — `gh issue create` (default)
- **GitLab** — `glab issue create`
- **Local markdown** — files under `docs/issues/`
- **Other** — ask user to describe in one paragraph

**C — Triage label vocabulary**

Five canonical roles (defaults shown). Ask if any should be overridden:

| Role | Default label |
|------|--------------|
| needs evaluation | `needs-triage` |
| waiting on reporter | `needs-info` |
| AFK-agent ready | `ready-for-agent` |
| human only | `ready-for-human` |
| won't fix | `wontfix` |


**D — Domain docs layout**

- **Single-context** — one `CONTEXT.md` + `docs/adr/` at repo root (most repos)
- **Multi-context** — `CONTEXT-MAP.md` pointing to per-package `CONTEXT.md` files (monorepos)

### 3. Confirm

Show draft of the `## Agent skills` block and all `docs/agents/*.md` files. Let user edit before writing.

### 4. Write

**File selection:**

- Edit `CLAUDE.md` if it exists
- Else edit `AGENTS.md` if it exists
- If neither exists, ask the user — don't pick for them

If `## Agent skills` already present, update in-place. Never duplicate.

**The block to add:**

```markdown
## Agent skills

### Issue tracker
[one-liner]. See `docs/agents/issue-tracker.md`.

### Triage labels
[one-liner]. See `docs/agents/triage-labels.md`.

### Domain docs
[single-context or multi-context]. See `docs/agents/domain.md`.
```

Write the three docs files from the seed templates in this skill's `assets/` folder, substituting real values (repo URL from `git remote -v`, actual label strings from the interview):

- [issue-tracker-github.md](./assets/issue-tracker-github.md) — for GitHub
- [issue-tracker-gitlab.md](./assets/issue-tracker-gitlab.md) — for GitLab
- [issue-tracker-local.md](./assets/issue-tracker-local.md) — for local markdown
- [triage-labels.md](./assets/triage-labels.md)
- [domain.md](./assets/domain.md)

**CONTEXT.md** — if not present at the repo root, create it from [CONTEXT.md](./assets/CONTEXT.md). Ask the user for the project name, one-paragraph description, and any key domain terms before writing. If `CONTEXT.md` already exists, do not overwrite it.

**PROJECT.md** — create at repo root from [PROJECT.md](./assets/PROJECT.md) when the user is running in project/AFK mode. Populate with the project goal, feature areas, and constraints gathered in interview section A. `afk.sh` includes this as context; GitHub issues are the source of truth for task order. If `PROJECT.md` already exists, do not overwrite it.

**PROMPT.md** — create at repo root from [PROMPT.md](./assets/PROMPT.md). This is the *how-to-work* file: agent methodology, signaling conventions (`<promise>COMPLETE</promise>`, `<promise>BLOCKED</promise>`), and project-specific code conventions. Ask the user for any project-specific conventions (language, formatter, test runner) before writing. If `PROMPT.md` already exists, do not overwrite it.

**`scripts/afk.sh` and `scripts/once.sh`** — copy from this skill's `scripts/` directory into the repo's `scripts/` directory. Create the directory if needed. Make both executable:

```bash
mkdir -p scripts
cp <skill-scripts>/afk.sh scripts/afk.sh
cp <skill-scripts>/once.sh scripts/once.sh
chmod +x scripts/afk.sh scripts/once.sh
```

Read the script content from this skill's `scripts/` folder and write it to the target repo directly if `cp` can't resolve the path.

**`issues/` directory** — create it if not present (used as fallback when GitHub auth is unavailable):

```bash
mkdir -p issues
```

Issue files must be named with a zero-padded index prefix: `001-slug.md`, `002-slug.md`, etc. PRD files follow the same convention: `PRD-001-feature.md`. The index determines execution order for `afk.sh`.

For GitHub issues, also create any missing labels:

```bash
gh label create needs-triage --color "#e4e669" --description "Maintainer needs to evaluate" 2>/dev/null || true
gh label create feature-tracker --color "#0075ca" --description "Tracks all issues for a project feature" 2>/dev/null || true
```

### 5. Done

Tell the user:

- Setup is complete and which files were written
- **Workflow**: `grill-me` → `write-a-prd` (per feature) → `to-issues` (per PRD) → `bash scripts/afk.sh <N>`
- **Progress tracking**: GitHub issues are the source of truth — open = todo, closed = done. Feature-tracker issues (created by `to-issues`) group slices under each feature. `afk-log.md` (written by `afk.sh`) records each iteration's signal.
- They can edit `docs/agents/*.md`, `PROJECT.md`, and `PROMPT.md` directly. Re-run ralph only to switch issue trackers or start over.