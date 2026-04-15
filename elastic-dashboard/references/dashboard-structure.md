# Dashboard Wrapper Structure

The top-level JSON file written to `kibana/dashboard/<package_name>-<uuid>.json`. Verified against real integration dashboards.

```json
{
  "attributes": {
    "controlGroupInput": {
      "chainingSystem": "NONE",
      "controlStyle": "oneLine",
      "ignoreParentSettingsJSON": "{\"ignoreFilters\":false,\"ignoreQuery\":false,\"ignoreTimerange\":false,\"ignoreValidations\":false}",
      "panelsJSON": "<SERIALIZED JSON STRING — see Control Group in panel-types.md>"
    },
    "description": "Overview of <Vendor> <Product> events",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": {
        "filter": [
          {
            "$state": { "store": "appState" },
            "meta": {
              "alias": null,
              "disabled": false,
              "indexRefName": "kibanaSavedObjectMeta.searchSourceJSON.filter[0].meta.index",
              "key": "data_stream.dataset",
              "negate": false,
              "params": { "query": "<package_name>.<data_stream>" },
              "type": "phrase"
            },
            "query": {
              "match_phrase": {
                "data_stream.dataset": "<package_name>.<data_stream>"
              }
            }
          }
        ],
        "query": { "language": "kuery", "query": "" }
      }
    },
    "optionsJSON": {
      "hidePanelTitles": false,
      "syncColors": false,
      "syncCursor": true,
      "syncTooltips": false,
      "useMargins": true
    },
    "panelsJSON": [
      // array of panel objects — see panel-types.md
    ],
    "timeRestore": false,
    "title": "<Vendor> <Product> Overview",
    "version": 1
  },
  "coreMigrationVersion": "8.8.0",
  "id": "<dashboard-uuid>",
  "references": [
    {
      "id": "logs-*",
      "name": "kibanaSavedObjectMeta.searchSourceJSON.filter[0].meta.index",
      "type": "index-pattern"
    }
    // one entry per Lens panel layer — see References section below
  ],
  "type": "dashboard",
  "typeMigrationVersion": "10.3.0"
}
```

## References array — critical naming convention

Every Lens panel layer and every map layer needs a reference entry. The naming is **NOT** just the internal ref name — it is prefixed with the panel's `panelIndex` UUID followed by a colon.

### Format
```
"<panelIndex>:<internal-ref-name>"
```

Where `<internal-ref-name>` exactly matches the `name` field inside `embeddableConfig.attributes.references[]`.

### Lens panel references
```json
{
  "id": "logs-*",
  "name": "<panelIndex>:indexpattern-datasource-layer-<layer-uuid>",
  "type": "index-pattern"
}
```

### Map panel references
```json
{ "id": "logs-*", "name": "<panelIndex>:layer_1_source_index_pattern", "type": "index-pattern" },
{ "id": "logs-*", "name": "<panelIndex>:layer_2_source_index_pattern", "type": "index-pattern" },
{ "id": "logs-*", "name": "<panelIndex>:layer_3_source_index_pattern", "type": "index-pattern" }
```

### Filter index reference (always first, no panelIndex prefix)
```json
{
  "id": "logs-*",
  "name": "kibanaSavedObjectMeta.searchSourceJSON.filter[0].meta.index",
  "type": "index-pattern"
}
```

### Links panel references (for dashboard links)
```json
{
  "id": "<target-dashboard-uuid>",
  "name": "<panelIndex>:link_<link-uuid>_dashboard",
  "type": "dashboard"
}
```

## Building the references array — step by step

1. Add the filter index reference first (no prefix)
2. For each Lens panel: add one entry per layer in its `embeddableConfig.attributes.references[]`, prefixing each `name` with `<panelIndex>:`
3. For each map panel: add entries for each ES layer (layer_1, layer_2, etc.) prefixed with `<panelIndex>:`
4. For each links panel with dashboard links: add entries prefixed with `<panelIndex>:`
