# claude-skills

A personal collection of Claude agent skills published via the `npx skills@latest` registry.

```bash
npx skills@latest add dot-mike/claude-skills/<skill-name>
```

---

## Ralph engineering suite

A set of skills for repo-level engineering workflows. **ralph** scaffolds the per-repo config (`docs/agents/`) that the other skills in this suite read.

Install the full suite — picks up all skills under `engineering/` and shows a multiselect prompt:

```bash
npx skills@latest add dot-mike/claude-skills/engineering
```

| Skill | Description |
|-------|-------------|
| **ralph** | Scaffold per-repo config (issue tracker, triage labels, domain docs). Run once per repo before the others. |
| **to-issues** | Break a PRD or spec into vertical-slice issues and publish to the issue tracker |
| **write-a-prd** | Synthesize conversation context into a structured PRD |
| **triage** | Triage issues through a state machine (needs-triage → ready/wontfix/needs-info) |
| **diagnose** | 6-phase diagnosis loop for hard bugs and performance regressions |
| **tdd** | Test-driven development with red-green-refactor loop |
| **improve-codebase-architecture** | Surface shallow modules and propose refactors |
| **zoom-out** | Get a module map with callers, data flows, and domain vocabulary |
| **grill-me** | Stress-test a plan or design through relentless questioning |
---

## Elasticsearch skills

```bash
npx skills@latest add dot-mike/claude-skills/elastic-dashboard
npx skills@latest add dot-mike/claude-skills/elastic-ingest-pipeline
```

| Skill | Description |
|-------|-------------|
| **elastic-dashboard** | Build Kibana dashboards for Elastic integrations |
| **elastic-ingest-pipeline** | Build and improve Elasticsearch ingest pipelines |

---

## General skills

```bash
npx skills@latest add dot-mike/claude-skills/write-a-skill
```

| Skill | Description |
|-------|-------------|
| **write-a-skill** | Create new agent skills with proper structure and bundled resources |
