# YAML Panel Examples

Full panel examples for every supported type in `kb-dashboard` YAML format.
For the authoritative schema, always run `kb-dashboard docs llms-full` first.

Replace `<package>.<stream>` with the actual `data_stream.dataset` value for the integration.

---

## ES|QL panels

All ES|QL panels share a common top-level structure:

```yaml
- title: Panel Title
  hide_title: false          # set true for section headers / KPIs that need no title
  size: {w: half, h: 10}
  esql:
    type: <chart-type>
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | ...
    # ... type-specific fields below
```

The `query` field accepts either a plain `|` multi-line string or a YAML sequence
of pipeline stages (one string per stage, no leading `|`).

---

### metric — KPI single value

```yaml
- hide_title: true
  size: {w: sixth, h: 4}
  esql:
    type: metric
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS total = COUNT(*)
    primary:
      field: total
      label: Total Events
      format:
        type: number
        decimals: 0

# With secondary (comparison) value:
- hide_title: true
  size: {w: quarter, h: 5}
  esql:
    type: metric
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | WHERE event.outcome == "failure"
      | STATS failed = COUNT(*), total = COUNT(*)
    primary:
      field: failed
      label: Failed Logins
      format:
        type: number
        decimals: 0
    secondary:
      field: total
      label: of total
```

---

### line — Trend over time

```yaml
- title: Events Over Time
  size: {w: whole, h: 10}
  esql:
    type: line
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
        label: Events
    legend:
      visible: show
      position: right

# With breakdown (one line per category):
- title: Events by Severity
  size: {w: whole, h: 10}
  esql:
    type: line
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY time_bucket = BUCKET(@timestamp, 20, ?_tstart, ?_tend), log.level
      | SORT time_bucket ASC
    dimension:
      field: time_bucket
      data_type: date
    metrics:
      - field: count
        label: Events
    breakdown:
      field: log.level
    legend:
      visible: show
      position: right
```

---

### area — Volume / stacked trends

```yaml
- title: Traffic Volume Over Time
  size: {w: whole, h: 10}
  esql:
    type: area
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY time_bucket = BUCKET(@timestamp, 20, ?_tstart, ?_tend), event.action
      | SORT time_bucket ASC
    dimension:
      field: time_bucket
      data_type: date
    metrics:
      - field: count
        label: Events
    breakdown:
      field: event.action
    legend:
      visible: show
      position: right
```

---

### bar — Category comparisons / histograms

```yaml
# Vertical bar (default)
- title: Events by Action
  size: {w: half, h: 10}
  esql:
    type: bar
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY event.action
      | SORT count DESC
      | LIMIT 10
    dimension:
      field: event.action
    metrics:
      - field: count
        label: Events

# Horizontal bar
- title: Top Source IPs
  size: {w: half, h: 10}
  esql:
    type: bar
    horizontal: true
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY source.ip
      | SORT count DESC
      | LIMIT 10
    dimension:
      field: source.ip
    metrics:
      - field: count
        label: Events

# Stacked bar over time
- title: Events by Type Over Time
  size: {w: whole, h: 10}
  esql:
    type: bar
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY time_bucket = BUCKET(@timestamp, 20, ?_tstart, ?_tend), event.category
      | SORT time_bucket ASC
    dimension:
      field: time_bucket
      data_type: date
    metrics:
      - field: count
        label: Events
    breakdown:
      field: event.category
    legend:
      visible: show
      position: right
```

---

### pie — Part-to-whole (use sparingly, ≤7 slices)

```yaml
- title: Events by Outcome
  size: {w: third, h: 10}
  esql:
    type: pie
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY event.outcome
      | SORT count DESC
    dimension:
      field: event.outcome
    metrics:
      - field: count
        label: Events

# Donut variant
- title: Events by Category
  size: {w: third, h: 10}
  esql:
    type: pie
    donut: true
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY event.category
      | SORT count DESC
      | LIMIT 7
    dimension:
      field: event.category
    metrics:
      - field: count
```

---

### datatable — Top N with multiple columns

```yaml
- title: Top Source IPs
  size: {w: whole, h: 12}
  esql:
    type: datatable
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*), countries = COUNT_DISTINCT(source.geo.country_name) BY source.ip
      | SORT count DESC
      | LIMIT 20
    dimensions:
      - field: source.ip
        label: Source IP
      - field: countries
        label: Countries
    metrics:
      - field: count
        label: Events
```

---

### heatmap — Two-dimensional intensity

```yaml
- title: Events by Hour and Day
  size: {w: whole, h: 10}
  esql:
    type: heatmap
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | EVAL hour = DATE_EXTRACT("HOUR_OF_DAY", @timestamp)
      | EVAL dow  = DATE_EXTRACT("DAY_OF_WEEK", @timestamp)
      | STATS count = COUNT(*) BY hour, dow
    x:
      field: hour
      label: Hour of Day
    y:
      field: dow
      label: Day of Week
    metric:
      field: count
      label: Events
```

---

### gauge — Progress toward a target

```yaml
- title: Authentication Success Rate
  size: {w: third, h: 8}
  esql:
    type: gauge
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | WHERE event.category == "authentication"
      | STATS success = COUNT(CASE WHEN event.outcome == "success" THEN 1 END), total = COUNT(*)
      | EVAL rate = success * 100.0 / total
    primary:
      field: rate
      label: Success Rate (%)
    min: 0
    max: 100
    goal: 95
```

---

### tagcloud — Term frequency

```yaml
- title: Top Event Actions
  size: {w: third, h: 10}
  esql:
    type: tagcloud
    query: |
      FROM logs-*
      | WHERE data_stream.dataset == "<package>.<stream>"
      | STATS count = COUNT(*) BY event.action
      | SORT count DESC
      | LIMIT 30
    dimension:
      field: event.action
    metrics:
      - field: count
```

---

## Non-ES|QL panels

### markdown — Section headers and context

```yaml
# Minimal section header (preferred)
- hide_title: true
  size: {w: whole, h: 3}
  markdown:
    content: '## Section Name'

# Rich context panel
- hide_title: true
  size: {w: third, h: 12}
  markdown:
    content: |
      ## Overview

      This dashboard shows:
      - Key security events and trends
      - Top source IPs and destinations
      - Authentication successes and failures

      Use the controls above to filter by specific fields.
```

---

### links — Dashboard navigation

```yaml
# Navigation bar (full width, 2 rows high)
- size: {w: whole, h: 2}
  links:
    layout: horizontal
    items:
      - label: Overview
        dashboard: package_name-overview
      - label: Network
        dashboard: package_name-network
      - label: Authentication
        dashboard: package_name-auth

# External URL link
- size: {w: quarter, h: 3}
  links:
    layout: vertical
    items:
      - label: Vendor Documentation
        url: https://example.com/docs
```

---

## Full dashboard skeleton (logs integration)

```yaml
dashboards:
  - id: package_name-overview
    name: "[Logs Package Name] Overview"
    description: Overview of Vendor Product events

    settings:
      margins: true
      sync:
        cursor: true
        tooltips: false
        colors: false

    filters:
      - field: data_stream.dataset
        equals: package_name.stream_name

    controls:
      - type: options
        label: Event Category
        data_view: logs-*
        field: event.category
      - type: options
        label: Event Outcome
        data_view: logs-*
        field: event.outcome

    panels:
      # Navigation
      - size: {w: whole, h: 2}
        links:
          layout: horizontal
          items:
            - label: Overview
              dashboard: package_name-overview
            - label: Network
              dashboard: package_name-network

      # Summary KPIs
      - hide_title: true
        size: {w: whole, h: 3}
        markdown:
          content: '## Summary'

      - hide_title: true
        size: {w: sixth, h: 4}
        esql:
          type: metric
          query: |
            FROM logs-*
            | WHERE data_stream.dataset == "package_name.stream_name"
            | STATS total = COUNT(*)
          primary:
            field: total
            label: Total Events
            format:
              type: number
              decimals: 0

      # ... more KPIs ...

      # Trends
      - hide_title: true
        size: {w: whole, h: 3}
        markdown:
          content: '## Trends'

      - title: Events Over Time
        size: {w: whole, h: 10}
        esql:
          type: bar
          query: |
            FROM logs-*
            | WHERE data_stream.dataset == "package_name.stream_name"
            | STATS count = COUNT(*) BY time_bucket = BUCKET(@timestamp, 20, ?_tstart, ?_tend)
            | SORT time_bucket ASC
          dimension:
            field: time_bucket
            data_type: date
          metrics:
            - field: count
              label: Events
          legend:
            visible: show
            position: right

      # Top N detail
      - hide_title: true
        size: {w: whole, h: 3}
        markdown:
          content: '## Top Sources'

      - title: Top Source IPs
        size: {w: whole, h: 12}
        esql:
          type: datatable
          query: |
            FROM logs-*
            | WHERE data_stream.dataset == "package_name.stream_name"
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
```

---

## Format options reference

The `format` block can appear on `primary`, `secondary`, and `metrics[]` items:

```yaml
format:
  type: number        # number | percent | bytes | duration | string
  decimals: 2
  suffix: "/sec"      # optional unit suffix
  prefix: "$"         # optional prefix
```

## Legend options

```yaml
legend:
  visible: show       # show | hide | auto
  position: right     # right | bottom | left | top
```

## Size shorthand

| Keyword | Width (of 48) |
|---|---|
| `whole` | 48 |
| `half` | 24 |
| `third` | 16 |
| `two-thirds` | 32 |
| `quarter` | 12 |
| `three-quarters` | 36 |
| `sixth` | 8 |
