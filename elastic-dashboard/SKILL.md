---
name: elastic-dashboard
description: Build Kibana dashboards for Elastic integrations. Use this skill whenever the user mentions building, creating, or updating a Kibana dashboard, working on elastic-integrations packages, generating dashboard JSON or YAML, adding panels to a dashboard, or visualizing integration data. Covers all panel types (ES|QL charts, Lens, geo Maps, links, markdown, controls). Outputs YAML source to _dev/shared/kibana/ and compiled JSON to kibana/dashboard/.
---

# Elastic Dashboard Builder

Build Kibana dashboards for Elastic integration packages.

**Primary approach: YAML dashboards** — human-readable YAML compiled to integration JSON via `kb-dashboard`. Designed for LLM-assisted development. Fall back to raw JSON only when migrating existing dashboards or when the compiler is unavailable.

---

## Workflow

### 1. Load schema and identify integration

Before writing any YAML, fetch the full compiler schema — it is the authoritative reference:

```bash
REQS=.github/workflows/validate-yaml-dashboards.requirements.txt
uvx --with-requirements "$REQS" --from kb-dashboard-cli==0.4.1 kb-dashboard docs llms-full
```

Always read these two guides:
```bash
uvx --with-requirements "$REQS" --from kb-dashboard-cli==0.4.1 kb-dashboard docs guide dashboard-style-guide
uvx --with-requirements "$REQS" --from kb-dashboard-cli==0.4.1 kb-dashboard docs guide esql-language-reference
```

If the integration is OTel-based (index pattern `metrics-*.otel-*` or `logs-*.otel-*`), also read:
```bash
uvx --with-requirements "$REQS" --from kb-dashboard-cli==0.4.1 kb-dashboard docs guide otel-dashboard-guide
```

If converting an existing JSON dashboard to YAML, also read:
```bash
uvx --with-requirements "$REQS" --from kb-dashboard-cli==0.4.1 kb-dashboard docs guide dashboard-decompiling-guide
```

Read the official dashboard guidelines (mandatory — apply these throughout):
```bash
cat docs/extend/dashboard-guidelines.md
```

Then read the integration's field definitions:
- `data_stream/*/fields/fields.yml` — integration-specific fields
- `data_stream/*/fields/ecs.yml` — ECS fields
- `data_stream/*/sample_event.json` — concrete document example
- `kibana/tags.yml` — tags to apply

If `elastic-mcp` tools are available, use them to check live field cardinality instead of static files.

### 2. Plan the dashboard

Answer these questions before writing any panels:
- **Who** is going to use this dashboard?
- **How much time** will users have — quick glance or deep investigation?
- **Main goal** and any secondary goals — what insight must be immediately visible?
- **Which fields** are most important to surface?
- **Split or single?** Prefer fewer visualizations per dashboard; split into overview + detail dashboards linked via a links panel rather than cramming everything onto one screen.

**Multi-dashboard integrations**: Create an overview dashboard linking to detail dashboards via a links panel. Follow the naming convention:
- Log integrations: `[Logs <PACKAGE NAME>] Overview`, `[Logs <PACKAGE NAME>] <Topic>`
- Metrics integrations: `[Metrics <PACKAGE NAME>] Overview`, `[Metrics <PACKAGE NAME>] <Topic>`

**Official guidelines — layout and organisation:**
- Keep related panels close together; use markdown headers as section dividers
- Most important charts at the top (summary/KPIs), increasing detail toward the bottom
- Place a prominent central chart (e.g. a wide time-series bar) as a visual focal point
- Always set `margins: true` — creates visual separation and a cleaner look
- **The `data_stream.dataset` filter is mandatory** — `elastic-package check` will FAIL the dashboard if this filter is missing. Set it at the dashboard level (in `filters:`) and ensure every ES|QL query also contains a matching `WHERE data_stream.dataset == "..."` clause
- Add controls (filter dropdowns) for the most-used keyword fields (hostname, instance, node, etc.) to allow switching between monitored instances

**Official guidelines — visualizations:**
- **Always use Lens** (ES|QL panels via `kb-dashboard` compile to Lens); never use TSVB
- Do NOT use library visualizations — all panels must be inline (by value)
- Avoid combining too many categories on one chart — split by category into separate charts when needed
- Use a neutral color for generic data; use an accented color only to highlight important signals
- Limit pie/donut charts to ≤7 slices; prefer bar charts for more categories
- **Counter metrics need rate transformation**: if a field has `metric_type: counter` in `fields.yml` (always increasing), use `RATE()` in ES|QL rather than raw values — e.g. `STATS req_rate = SUM(RATE(requests_total)) BY time_bucket`

**Official guidelines — titles:**
- Do NOT include the package name in panel titles (e.g., avoid `[My Package Logs] Top IPs`) — the dashboard title provides context
- When a panel title is self-explanatory, remove axis titles and other redundant labels to give more space to the chart itself
- Use `hide_title: true` for section-header markdown panels and KPI metrics that speak for themselves

### 3. Write the YAML dashboard

Output file: `packages/<package_name>/_dev/shared/kibana/<name>.yaml`

```yaml
dashboards:
  - id: <package_name>-overview
    name: "[Logs <Package Name>] Overview"
    description: Overview of <Vendor> <Product> events

    settings:
      margins: true
      sync:
        cursor: true
        tooltips: false
        colors: false

    filters:
      - field: data_stream.dataset
        equals: <package_name>.<data_stream>

    controls:
      - type: options
        label: <Field Label>
        data_view: logs-*
        field: <field.name>

    panels:
      # Navigation (if multi-dashboard)
      - size: {w: whole, h: 2}
        links:
          layout: horizontal
          items:
            - label: Overview
              dashboard: <package_name>-overview

      # Section header
      - hide_title: true
        size: {w: whole, h: 3}
        markdown:
          content: '## Section Name'

      # Panel examples below — see Quick Reference
```

**Size shorthand** (preferred over numeric `{w, h}`):

| Keyword | Width (of 48) |
|---|---|
| `whole` | 48 |
| `half` | 24 |
| `third` | 16 |
| `two-thirds` | 32 |
| `quarter` | 12 |
| `three-quarters` | 36 |
| `sixth` | 8 |

### 4. Lint and compile

```bash
cd packages/<package_name>
REQS=../../.github/workflows/validate-yaml-dashboards.requirements.txt

# Lint
uvx --with-requirements "$REQS" --from kb-dashboard-lint==0.4.1 kb-dashboard-lint check \
    --input-file _dev/shared/kibana/<name>.yaml

# Compile to JSON
uvx --with-requirements "$REQS" --from kb-dashboard-cli==0.4.1 kb-dashboard compile \
    --input-dir _dev/shared/kibana \
    --output-dir kibana/dashboard \
    --format "elastic-integrations"
```

If a running Kibana is available (e.g., via `elastic-package`), upload to verify visually:
```bash
uvx --with-requirements "$REQS" --from kb-dashboard-cli==0.4.1 kb-dashboard compile \
    --input-file _dev/shared/kibana/<name>.yaml \
    --upload \
    --kibana-url http://localhost:5601 \
    --kibana-username elastic \
    --kibana-password changeme
```

Fix linting errors by feeding them back into the YAML. Commit **both** the YAML source and compiled JSON.

### 5. Validate

Run toolchain checks:
```bash
# Lint YAML
uvx --with-requirements "$REQS" --from kb-dashboard-lint==0.4.1 kb-dashboard-lint check \
    --input-file _dev/shared/kibana/<name>.yaml

# elastic-package check — validates dataset filter, file naming, JSON correctness
elastic-package check -v
```

**Technical:**
- JSON is valid and compiles without errors
- Every `panelIndex` is unique in the compiled JSON
- `data_stream.dataset` filter is set at the dashboard level AND in every ES|QL query (`WHERE data_stream.dataset == "..."`) — `elastic-package check` FAILS without this
- Dashboard JSON filename follows `<package_name>-<uuid>.json` — never use `-ecs` or `-ECS` suffix (forbidden by spec)
- Dashboard name follows convention: `[Logs <PACKAGE NAME>] <Name>` or `[Metrics <PACKAGE NAME>] <Name>`
- No library visualization references (all inline by value)
- `margins: true` is set in dashboard settings
- Counter metrics use `RATE()` in ES|QL, not raw field values

**Guidelines checklist:**
- Most important panels are at the top; detail increases toward the bottom
- Panel titles are concise — no package name prefix, no redundant axis labels
- No single dashboard has too many visualizations (split if crowded)
- Controls are present for the most-used filter fields (hostname, instance, etc.)
- Pie/donut charts have ≤7 slices
- Related panels are grouped with a markdown section header

**Screenshots** (required for published integrations):
- Add at least one dashboard screenshot to `img/` as a PNG
- Use proper casing in screenshot descriptions (shown in Kibana Integration Manager): `Kibana running on AWS EC2` not `kibana running on ec2`

---

## Quick panel reference (YAML)

Read `references/yaml-panels.md` for full examples. Summary:

### ES|QL panel types (`esql:`)

| Chart type | `type:` value | Use for |
|---|---|---|
| KPI single value | `metric` | Total counts, unique IPs, rates |
| Line chart | `line` | Trends over time |
| Area chart | `area` | Volume/stacked trends over time |
| Bar chart | `bar` | Category comparisons, histograms |
| Pie / donut | `pie` | Part-to-whole (use sparingly, ≤7 slices) |
| Data table | `datatable` | Top N with multiple columns |
| Heatmap | `heatmap` | Two-dimensional intensity |
| Gauge | `gauge` | Progress toward a target |
| Tag cloud | `tagcloud` | Term frequency |

### Non-ES|QL panels

| Panel | Syntax | Use for |
|---|---|---|
| Markdown | `markdown: content: \|` | Section headers, context, navigation links |
| Links | `links: layout: horizontal` | Dashboard navigation, external URLs |

### Controls (filter dropdowns)

```yaml
controls:
  - type: options
    label: Event Category
    data_view: logs-*
    field: event.category
  - type: options
    label: Event Outcome
    data_view: logs-*
    field: event.outcome
```

---

## ES|QL query patterns for security/log integrations

```yaml
# Count over time (bar/line/area)
esql:
  type: bar
  query: |
    FROM logs-*
    | WHERE data_stream.dataset == "<package>.<stream>"
    | STATS count = COUNT(*) BY time_bucket = BUCKET(@timestamp, 20, ?_tstart, ?_tend)
    | SORT time_bucket ASC
  dimension:
    field: time_bucket
    data_type: date
  metrics:
    - field: count

# Top N categories (pie or bar)
esql:
  type: pie
  query: |
    FROM logs-*
    | WHERE data_stream.dataset == "<package>.<stream>"
    | STATS count = COUNT(*) BY event.category
    | SORT count DESC
    | LIMIT 10
  dimension:
    field: event.category
  metrics:
    - field: count

# Single KPI
esql:
  type: metric
  query: |
    FROM logs-*
    | WHERE data_stream.dataset == "<package>.<stream>"
    | STATS total = COUNT(*)
  primary:
    field: total
    label: Total Events

# Top N table (datatable)
esql:
  type: datatable
  query: |
    FROM logs-*
    | WHERE data_stream.dataset == "<package>.<stream>"
    | STATS count = COUNT(*) BY source.ip, source.geo.country_name
    | SORT count DESC
    | LIMIT 20
  dimensions:
    - field: source.ip
      label: Source IP
    - field: source.geo.country_name
      label: Country
  metrics:
    - field: count
      label: Events

# Counter metric rate over time (use RATE() for metric_type: counter fields)
esql:
  type: line
  query: |
    FROM metrics-*
    | WHERE data_stream.dataset == "<package>.<stream>"
    | STATS req_rate = SUM(RATE(requests_total)) BY time_bucket = BUCKET(@timestamp, 20, ?_tstart, ?_tend)
    | SORT time_bucket ASC
  dimension:
    field: time_bucket
    data_type: date
  metrics:
    - field: req_rate
      label: Requests/sec
```

---

## Raw JSON fallback

Only use raw JSON when:
- Migrating an existing JSON dashboard that pre-dates the YAML format
- The `kb-dashboard` toolchain is not available
- You need a panel type not yet supported by the compiler

See `references/dashboard-structure.md` and `references/panel-types.md` for full JSON templates.

**Critical JSON rules (verified from real dashboards):**
- Top-level references use `<panelIndex>:indexpattern-datasource-layer-<uuid>` naming (panelIndex prefix required)
- `lnsTagcloud` uses `tagAccessor`/`valueAccessor` (not `bucketAccessor`/`metric`)
- `lnsChoropleth` uses `emsField` (not `regionField`)
- Control group `panelsJSON` must be a serialized JSON string
- No `version` field on links panels or markdown panels
