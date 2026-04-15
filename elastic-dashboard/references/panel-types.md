# Panel Type Templates

Each panel is an object in the `attributes.panelsJSON` array. Replace all `<UUID-*>` placeholders with fresh UUID v4 values.

## Grid system

Dashboard is 48 columns wide. Rows stack vertically by `y`. Common sizes:
- Small panel: `w: 12, h: 7`
- Half-width: `w: 24, h: 12`
- Full-width: `w: 48, h: 12`
- Map panel: `w: 24, h: 25`

---

## 1. Treemap (lnsPie — category distribution)

Use for: keyword fields like `event.category`, `event.outcome`, `event.action`, `log.level`, `network.direction`.

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-BUCKET>", "<UUID-METRIC>"],
                "columns": {
                  "<UUID-METRIC>": {
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Count of records",
                    "operationType": "count",
                    "params": { "emptyAsNull": true },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  },
                  "<UUID-BUCKET>": {
                    "dataType": "string",
                    "isBucketed": true,
                    "label": "Top 5 values of <field.name>",
                    "operationType": "terms",
                    "params": {
                      "missingBucket": false,
                      "orderBy": { "columnId": "<UUID-METRIC>", "type": "column" },
                      "orderDirection": "desc",
                      "otherBucket": false,
                      "parentFormat": { "id": "terms" },
                      "size": 5
                    },
                    "scale": "ordinal",
                    "sourceField": "<field.name>"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "layers": [
            {
              "categoryDisplay": "default",
              "groups": ["<UUID-BUCKET>"],
              "layerId": "<UUID-LAYER>",
              "layerType": "data",
              "legendDisplay": "default",
              "metric": "<UUID-METRIC>",
              "nestedLegend": false,
              "numberDisplay": "percent"
            }
          ],
          "shape": "treemap"
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsPie"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 7, "i": "<UUID-PANEL>", "w": 12, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "<Panel Title>",
  "type": "lens",
  "version": "8.11.0"
}
```

For **pie/donut** instead of treemap, change `"shape": "treemap"` → `"shape": "pie"` or `"shape": "donut"`.

---

## 2. Time Series Line Chart (lnsXY — events over time)

Use for: `@timestamp` x-axis with count or metric on y-axis.

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-DATE>", "<UUID-METRIC>"],
                "columns": {
                  "<UUID-DATE>": {
                    "dataType": "date",
                    "isBucketed": true,
                    "label": "@timestamp",
                    "operationType": "date_histogram",
                    "params": {
                      "dropPartials": false,
                      "includeEmptyRows": true,
                      "interval": "auto"
                    },
                    "scale": "interval",
                    "sourceField": "@timestamp"
                  },
                  "<UUID-METRIC>": {
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Count of records",
                    "operationType": "count",
                    "params": { "emptyAsNull": true },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "axisTitlesVisibilitySettings": { "x": true, "yLeft": true, "yRight": true },
          "fittingFunction": "None",
          "gridlinesVisibilitySettings": { "x": true, "yLeft": true, "yRight": true },
          "labelsOrientation": { "x": 0, "yLeft": 0, "yRight": 0 },
          "layers": [
            {
              "accessors": ["<UUID-METRIC>"],
              "layerId": "<UUID-LAYER>",
              "layerType": "data",
              "position": "top",
              "seriesType": "line",
              "showGridlines": false,
              "xAccessor": "<UUID-DATE>"
            }
          ],
          "legend": { "isVisible": true, "position": "right" },
          "preferredSeriesType": "line",
          "tickLabelsVisibilitySettings": { "x": true, "yLeft": true, "yRight": true },
          "valueLabels": "hide"
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsXY"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 12, "i": "<UUID-PANEL>", "w": 48, "x": 0, "y": 14 },
  "panelIndex": "<UUID-PANEL>",
  "title": "Events Over Time",
  "type": "lens",
  "version": "8.11.0"
}
```

For a **metric over time** (e.g., bytes), replace the `<UUID-METRIC>` column with:
```json
{
  "dataType": "number",
  "isBucketed": false,
  "label": "Median of <field.name>",
  "operationType": "median",
  "params": { "emptyAsNull": true },
  "scale": "ratio",
  "sourceField": "<field.name>"
}
```

---

## 3. Stacked Bar Chart / Histogram (lnsXY — bar_stacked)

Use for: numeric range distributions (`log.syslog.severity.code`, `event.duration`, `network.bytes`).

Change the x-axis column from `date_histogram` to `range`:
```json
"<UUID-BUCKET>": {
  "customLabel": true,
  "dataType": "number",
  "isBucketed": true,
  "label": "<Axis Label>",
  "operationType": "range",
  "params": {
    "includeEmptyRows": true,
    "maxBars": "auto",
    "ranges": [{ "from": 0, "label": "", "to": 1000 }],
    "type": "histogram"
  },
  "scale": "interval",
  "sourceField": "<field.name>"
}
```

In the visualization block, use:
```json
"layers": [
  {
    "accessors": ["<UUID-METRIC>"],
    "layerId": "<UUID-LAYER>",
    "layerType": "data",
    "seriesType": "bar_stacked",
    "xAccessor": "<UUID-BUCKET>"
  }
],
"preferredSeriesType": "bar_stacked"
```

For a **terms-based bar chart** (e.g., top IPs by count), use `operationType: "terms"` in the bucket column (same as treemap), but use the XY visualization instead of pie.

---

## 4. Metric Panel (lnsMetric — single KPI)

Use for: total event count, unique source IPs, etc.

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-METRIC>"],
                "columns": {
                  "<UUID-METRIC>": {
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Count of records",
                    "operationType": "count",
                    "params": { "emptyAsNull": true },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "layerId": "<UUID-LAYER>",
          "layerType": "data",
          "metricAccessor": "<UUID-METRIC>"
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsMetric"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 4, "i": "<UUID-PANEL>", "w": 8, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "Total Events",
  "type": "lens",
  "version": "8.11.0"
}
```

For **unique count** (e.g., unique source IPs), use:
```json
"operationType": "unique_count",
"sourceField": "source.ip"
```

---

## 5. Data Table (lnsDatatable)

Use for: showing top N rows with multiple fields (e.g., top source IPs with count and country).

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-BUCKET>", "<UUID-METRIC>"],
                "columns": {
                  "<UUID-BUCKET>": {
                    "dataType": "string",
                    "isBucketed": true,
                    "label": "Top 10 values of <field.name>",
                    "operationType": "terms",
                    "params": {
                      "missingBucket": false,
                      "orderBy": { "columnId": "<UUID-METRIC>", "type": "column" },
                      "orderDirection": "desc",
                      "otherBucket": false,
                      "parentFormat": { "id": "terms" },
                      "size": 10
                    },
                    "scale": "ordinal",
                    "sourceField": "<field.name>"
                  },
                  "<UUID-METRIC>": {
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Count of records",
                    "operationType": "count",
                    "params": { "emptyAsNull": true },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "columns": [
            { "columnId": "<UUID-BUCKET>", "isTransposed": false },
            { "columnId": "<UUID-METRIC>", "isTransposed": false }
          ],
          "layerId": "<UUID-LAYER>",
          "layerType": "data",
          "rowHeight": "single",
          "rowHeightLines": 1
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsDatatable"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 10, "i": "<UUID-PANEL>", "w": 24, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "Top Source IPs",
  "type": "lens",
  "version": "8.11.0"
}
```

---

## 6. Gauge (lnsGauge)

Use for: showing a metric relative to a max (e.g., alert rate, fill percentage). Verified against real integration dashboards.

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-METRIC>", "<UUID-MIN>", "<UUID-MAX>"],
                "columns": {
                  "<UUID-METRIC>": {
                    "customLabel": true,
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "<Metric Label>",
                    "operationType": "count",
                    "params": { "emptyAsNull": true },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  },
                  "<UUID-MIN>": {
                    "customLabel": true,
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Static value: 0",
                    "operationType": "static_value",
                    "params": { "value": "0" },
                    "references": [],
                    "scale": "ratio"
                  },
                  "<UUID-MAX>": {
                    "customLabel": true,
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Static value: 100",
                    "operationType": "static_value",
                    "params": { "value": "100" },
                    "references": [],
                    "scale": "ratio"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "colorMode": "palette",
          "labelMajorMode": "auto",
          "layerId": "<UUID-LAYER>",
          "layerType": "data",
          "metricAccessor": "<UUID-METRIC>",
          "minAccessor": "<UUID-MIN>",
          "maxAccessor": "<UUID-MAX>",
          "shape": "horizontalBullet",
          "ticksPosition": "bands",
          "palette": {
            "name": "custom",
            "type": "palette",
            "params": {
              "continuity": "all",
              "name": "custom",
              "progression": "fixed",
              "rangeMax": null,
              "rangeMin": null,
              "rangeType": "percent",
              "reverse": false,
              "steps": 3,
              "stops": [
                { "color": "#54B399", "stop": 33 },
                { "color": "#D6BF57", "stop": 66 },
                { "color": "#E7664C", "stop": 100 }
              ]
            }
          }
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsGauge"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 8, "i": "<UUID-PANEL>", "w": 12, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "<Gauge Title>",
  "type": "lens",
  "version": "8.11.0"
}
```

---

## 7. Geo Map Panel

Use when the integration has `source.geo.location` or `destination.geo.location` fields.

This panel uses `"type": "map"` (not `"lens"`). The map config is stored as serialized JSON strings inside `layerListJSON` and `mapStateJSON`.

```json
{
  "embeddableConfig": {
    "attributes": {
      "description": "",
      "layerListJSON": "[{\"locale\":\"autoselect\",\"sourceDescriptor\":{\"type\":\"EMS_TMS\",\"isAutoSelect\":true,\"lightModeDefault\":\"road_map_desaturated\"},\"id\":\"<UUID-BASE>\",\"label\":null,\"minZoom\":0,\"maxZoom\":24,\"alpha\":1,\"visible\":true,\"style\":{\"type\":\"TILE\"},\"includeInFitToBounds\":true,\"type\":\"EMS_VECTOR_TILE\"},{\"sourceDescriptor\":{\"sourceGeoField\":\"source.geo.location\",\"destGeoField\":\"destination.geo.location\",\"id\":\"<UUID-PEW>\",\"type\":\"ES_PEW_PEW\",\"applyGlobalQuery\":true,\"applyGlobalTime\":true,\"applyForceRefresh\":true,\"metrics\":[{\"type\":\"count\"}],\"indexPatternRefName\":\"layer_1_source_index_pattern\"},\"style\":{\"type\":\"VECTOR\",\"properties\":{\"fillColor\":{\"type\":\"STATIC\",\"options\":{\"color\":\"#54B399\"}},\"lineColor\":{\"type\":\"DYNAMIC\",\"options\":{\"color\":\"Blues\",\"field\":{\"name\":\"doc_count\",\"origin\":\"source\"},\"fieldMetaOptions\":{\"isEnabled\":true,\"sigma\":3}}},\"lineWidth\":{\"type\":\"DYNAMIC\",\"options\":{\"minSize\":1,\"maxSize\":10,\"field\":{\"name\":\"doc_count\",\"origin\":\"source\"},\"fieldMetaOptions\":{\"isEnabled\":true,\"sigma\":3}}}}},\"id\":\"<UUID-PEW-LAYER>\",\"label\":null,\"minZoom\":0,\"maxZoom\":24,\"alpha\":0.75,\"visible\":true,\"includeInFitToBounds\":true,\"type\":\"GEOJSON_VECTOR\",\"joins\":[]},{\"sourceDescriptor\":{\"geoField\":\"destination.geo.location\",\"requestType\":\"heatmap\",\"resolution\":\"MOST_FINE\",\"id\":\"<UUID-DST-HEAT>\",\"type\":\"ES_GEO_GRID\",\"applyGlobalQuery\":true,\"applyGlobalTime\":true,\"applyForceRefresh\":true,\"metrics\":[{\"type\":\"count\"}],\"indexPatternRefName\":\"layer_2_source_index_pattern\"},\"id\":\"<UUID-DST-LAYER>\",\"label\":\"Destination Location\",\"minZoom\":0,\"maxZoom\":24,\"alpha\":0.75,\"visible\":true,\"style\":{\"type\":\"HEATMAP\",\"colorRampName\":\"Blues\"},\"includeInFitToBounds\":true,\"type\":\"HEATMAP\"},{\"sourceDescriptor\":{\"geoField\":\"source.geo.location\",\"requestType\":\"heatmap\",\"resolution\":\"MOST_FINE\",\"id\":\"<UUID-SRC-HEAT>\",\"type\":\"ES_GEO_GRID\",\"applyGlobalQuery\":true,\"applyGlobalTime\":true,\"applyForceRefresh\":true,\"metrics\":[{\"type\":\"count\"}],\"indexPatternRefName\":\"layer_3_source_index_pattern\"},\"id\":\"<UUID-SRC-LAYER>\",\"label\":\"Source Location\",\"minZoom\":0,\"maxZoom\":24,\"alpha\":0.75,\"visible\":true,\"style\":{\"type\":\"HEATMAP\",\"colorRampName\":\"Yellow to Red\"},\"includeInFitToBounds\":true,\"type\":\"HEATMAP\"}]",
      "mapStateJSON": "{\"zoom\":1.64,\"center\":{\"lon\":0,\"lat\":0},\"timeFilters\":{\"from\":\"now-7d\",\"to\":\"now\"},\"refreshConfig\":{\"isPaused\":true,\"interval\":0},\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filters\":[],\"settings\":{\"autoFitToDataBounds\":false,\"backgroundColor\":\"#ffffff\",\"customIcons\":[],\"disableInteractive\":false,\"hideToolbarOverlay\":false,\"hideLayerControl\":false,\"hideViewControl\":false,\"initialLocation\":\"LAST_SAVED_LOCATION\",\"showScaleControl\":false,\"showSpatialFilters\":true,\"showTimesliderToggleButton\":true}}",
      "title": "",
      "uiStateJSON": "{\"isLayerTOCOpen\":true,\"openTOCDetails\":[]}"
    },
    "enhancements": {},
    "hiddenLayers": [],
    "hidePanelTitles": false,
    "isLayerTOCOpen": false,
    "mapBuffer": {
      "maxLat": 89.78601, "maxLon": 360,
      "minLat": -89.78601, "minLon": -180
    },
    "mapCenter": { "lat": 0, "lon": 0, "zoom": 1.64 },
    "openTOCDetails": []
  },
  "gridData": { "h": 25, "i": "<UUID-PANEL>", "w": 24, "x": 0, "y": 38 },
  "panelIndex": "<UUID-PANEL>",
  "title": "Connections",
  "type": "map",
  "version": "8.11.0"
}
```

Map layers need references in the top-level `references` array:
```json
{ "id": "logs-*", "name": "layer_1_source_index_pattern", "type": "index-pattern" },
{ "id": "logs-*", "name": "layer_2_source_index_pattern", "type": "index-pattern" },
{ "id": "logs-*", "name": "layer_3_source_index_pattern", "type": "index-pattern" }
```

---

## 8. Control Group (filter dropdowns)

The control group is NOT in `panelsJSON`. It lives in `attributes.controlGroupInput.panelsJSON` as a **serialized JSON string**.

Each control is an `optionsListControl` keyed by a UUID:

```json
{
  "<UUID-CTRL-1>": {
    "order": 0,
    "width": "medium",
    "grow": true,
    "type": "optionsListControl",
    "explicitInput": {
      "fieldName": "<field.name>",
      "title": "<Filter Label>",
      "id": "<UUID-CTRL-1>",
      "enhancements": {},
      "selectedOptions": []
    }
  },
  "<UUID-CTRL-2>": {
    "order": 1,
    "width": "medium",
    "grow": true,
    "type": "optionsListControl",
    "explicitInput": {
      "fieldName": "<field.name>",
      "title": "<Filter Label>",
      "id": "<UUID-CTRL-2>",
      "enhancements": {}
    }
  }
}
```

This entire object must be **JSON.stringify'd** and set as the value of `controlGroupInput.panelsJSON`.

Typical controls for a security integration:
1. `fortinet.firewall.type` / vendor-specific type field → "Firewall Operation Type"
2. `event.category` → "Event Category"
3. `event.outcome` → "Event Outcome"
4. `event.action` → "Event Action"
5. `log.level` → "Log Level"

---

---

## 9. Area Chart (lnsXY — area / area_stacked)

Same structure as the line chart (section 2), but change `seriesType` in the visualization layer:

```json
"layers": [
  {
    "accessors": ["<UUID-METRIC>"],
    "layerId": "<UUID-LAYER>",
    "layerType": "data",
    "seriesType": "area_stacked",
    "xAccessor": "<UUID-DATE>"
  }
],
"preferredSeriesType": "area_stacked"
```

Use `"area"` for non-stacked, `"area_stacked"` for stacked. Good for showing multiple series (e.g., inbound vs outbound traffic) layered over time.

---

## 10. Horizontal Bar Chart (lnsXY — bar_horizontal / bar_horizontal_stacked)

Same structure as section 3 (stacked bar), but use `"seriesType": "bar_horizontal"` or `"bar_horizontal_stacked"`. Good for ranked lists (top source IPs, top destinations) when labels are long.

```json
"layers": [
  {
    "accessors": ["<UUID-METRIC>"],
    "layerId": "<UUID-LAYER>",
    "layerType": "data",
    "seriesType": "bar_horizontal",
    "xAccessor": "<UUID-BUCKET>"
  }
],
"preferredSeriesType": "bar_horizontal"
```

---

## 11. Heatmap (lnsHeatmap)

Use for: showing intensity of a metric across two dimensions (e.g., event type vs. source country). Verified against real integration dashboards.

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-X>", "<UUID-Y>", "<UUID-METRIC>"],
                "columns": {
                  "<UUID-X>": {
                    "dataType": "date",
                    "isBucketed": true,
                    "label": "@timestamp",
                    "operationType": "date_histogram",
                    "params": { "interval": "auto", "dropPartials": false, "includeEmptyRows": true },
                    "scale": "interval",
                    "sourceField": "@timestamp"
                  },
                  "<UUID-Y>": {
                    "dataType": "string",
                    "isBucketed": true,
                    "label": "Top 10 values of <field.name>",
                    "operationType": "terms",
                    "params": {
                      "size": 10,
                      "orderBy": { "columnId": "<UUID-METRIC>", "type": "column" },
                      "orderDirection": "desc",
                      "missingBucket": false,
                      "otherBucket": false,
                      "parentFormat": { "id": "terms" }
                    },
                    "scale": "ordinal",
                    "sourceField": "<field.name>"
                  },
                  "<UUID-METRIC>": {
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Count of records",
                    "operationType": "count",
                    "params": { "emptyAsNull": true },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "layerId": "<UUID-LAYER>",
          "layerType": "data",
          "legend": {
            "isVisible": true,
            "position": "right",
            "shouldTruncate": false,
            "type": "heatmap_legend"
          },
          "palette": {
            "accessor": "<UUID-METRIC>",
            "name": "custom",
            "type": "palette",
            "params": {
              "continuity": "above",
              "name": "custom",
              "rangeMax": null,
              "rangeMin": 0,
              "rangeType": "percent",
              "steps": 5,
              "stops": [
                { "color": "#6092c0", "stop": 10 },
                { "color": "#a8bfda", "stop": 20 },
                { "color": "#ebeff5", "stop": 30 },
                { "color": "#ecb385", "stop": 40 },
                { "color": "#e7664c", "stop": 50 }
              ]
            }
          },
          "shape": "heatmap",
          "valueAccessor": "<UUID-METRIC>",
          "xAccessor": "<UUID-X>",
          "yAccessor": "<UUID-Y>"
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsHeatmap"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 12, "i": "<UUID-PANEL>", "w": 24, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "<Heatmap Title>",
  "type": "lens",
  "version": "8.11.0"
}
```

---

## 12. Tag Cloud (lnsTagcloud)

Use for: visualizing keyword frequency — good for event actions, rule names, user agents. Verified against real integration dashboards.

Note: the visualization uses `tagAccessor` and `valueAccessor` (NOT `bucketAccessor`/`metric` — those are wrong).

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-BUCKET>", "<UUID-METRIC>"],
                "columns": {
                  "<UUID-BUCKET>": {
                    "dataType": "string",
                    "isBucketed": true,
                    "label": "Top 10 values of <field.name>",
                    "operationType": "terms",
                    "params": {
                      "size": 10,
                      "orderBy": { "columnId": "<UUID-METRIC>", "type": "column" },
                      "orderDirection": "desc",
                      "missingBucket": false,
                      "otherBucket": false,
                      "parentFormat": { "id": "terms" }
                    },
                    "scale": "ordinal",
                    "sourceField": "<field.name>"
                  },
                  "<UUID-METRIC>": {
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Count of records",
                    "operationType": "count",
                    "params": { "emptyAsNull": true },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "colorMapping": {
            "assignments": [],
            "colorMode": { "type": "categorical" },
            "paletteId": "eui_amsterdam_color_blind",
            "specialAssignments": [
              {
                "color": { "type": "loop" },
                "rule": { "type": "other" },
                "touched": false
              }
            ]
          },
          "layerId": "<UUID-LAYER>",
          "layerType": "data",
          "maxFontSize": 72,
          "minFontSize": 18,
          "orientation": "single",
          "showLabel": true,
          "tagAccessor": "<UUID-BUCKET>",
          "valueAccessor": "<UUID-METRIC>"
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsTagcloud"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 10, "i": "<UUID-PANEL>", "w": 24, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "<Tag Cloud Title>",
  "type": "lens",
  "version": "8.11.0"
}
```

---

## 13. Mosaic / Waffle (lnsPie variants)

**Mosaic** — like a treemap but shows proportions of two dimensions. Use for: breakdown of one field split by another (e.g., event.action split by event.outcome).

**Waffle** — square grid showing proportion. Use for: simple single-value proportion (e.g., % of denied traffic).

Both use `visualizationType: "lnsPie"`. Change `shape` in the visualization:
- Mosaic: `"shape": "mosaic"` — requires two bucket columns (`groups` array with two entries)
- Waffle: `"shape": "waffle"` — same structure as pie/treemap (single bucket)

Mosaic example visualization block:
```json
"visualization": {
  "layers": [
    {
      "categoryDisplay": "default",
      "groups": ["<UUID-BUCKET-1>", "<UUID-BUCKET-2>"],
      "layerId": "<UUID-LAYER>",
      "layerType": "data",
      "legendDisplay": "default",
      "metric": "<UUID-METRIC>",
      "nestedLegend": false,
      "numberDisplay": "percent"
    }
  ],
  "shape": "mosaic"
}
```

Add a second `terms` bucket column (`<UUID-BUCKET-2>`) for the split field.

---

---

## 14. Links Panel

Use for: navigation between dashboards, external URLs, or quick-access links. Verified against real integration dashboards.

```json
{
  "embeddableConfig": {
    "attributes": {
      "layout": "horizontal",
      "links": [
        {
          "destinationRefName": "link_<UUID-LINK-1>_dashboard",
          "id": "<UUID-LINK-1>",
          "label": "<Dashboard Link Label>",
          "options": {
            "openInNewTab": false,
            "useCurrentDateRange": false,
            "useCurrentFilters": false
          },
          "order": 0,
          "type": "dashboardLink"
        },
        {
          "id": "<UUID-LINK-2>",
          "label": "<External Link Label>",
          "options": {
            "openInNewTab": true,
            "encodeUrl": true
          },
          "order": 1,
          "type": "externalLink",
          "destination": "https://example.com"
        }
      ]
    }
  },
  "gridData": { "h": 4, "i": "<UUID-PANEL>", "w": 48, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "type": "links"
}
```

**Dashboard links** require a reference in the top-level `references` array:
```json
{
  "id": "<target-dashboard-uuid>",
  "name": "link_<UUID-LINK-1>_dashboard",
  "type": "dashboard"
}
```

**External links** (`type: "externalLink"`) need no reference entry.

`layout` options: `"horizontal"` (row of buttons, most common) or `"vertical"` (stacked list).

Note: links panels do NOT have a top-level `"version"` field in real integration dashboards.

---

---

## 15. Region Map / Choropleth (lnsChoropleth)

Use for: showing how a metric varies across geographic regions using color intensity (e.g., event count by country). Requires a field with ISO country codes (`source.geo.country_iso_code`) or similar regional identifiers. Verified against real integration dashboards.

Note: the visualization uses `emsField` (NOT `regionField` — that key is wrong).

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [
        {
          "id": "logs-*",
          "name": "indexpattern-datasource-layer-<UUID-LAYER>",
          "type": "index-pattern"
        }
      ],
      "state": {
        "datasourceStates": {
          "indexpattern": {
            "layers": {
              "<UUID-LAYER>": {
                "columnOrder": ["<UUID-REGION>", "<UUID-METRIC>"],
                "columns": {
                  "<UUID-REGION>": {
                    "customLabel": true,
                    "dataType": "string",
                    "isBucketed": true,
                    "label": "<Region Label>",
                    "operationType": "terms",
                    "params": {
                      "exclude": [],
                      "excludeIsRegex": false,
                      "include": [],
                      "includeIsRegex": false,
                      "missingBucket": false,
                      "orderBy": { "columnId": "<UUID-METRIC>", "type": "column" },
                      "orderDirection": "desc",
                      "otherBucket": true,
                      "parentFormat": { "id": "terms" },
                      "size": 10
                    },
                    "scale": "ordinal",
                    "sourceField": "source.geo.country_iso_code"
                  },
                  "<UUID-METRIC>": {
                    "customLabel": true,
                    "dataType": "number",
                    "isBucketed": false,
                    "label": "Count",
                    "operationType": "count",
                    "params": { "emptyAsNull": false },
                    "scale": "ratio",
                    "sourceField": "___records___"
                  }
                },
                "incompleteColumns": {}
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "kuery", "query": "" },
        "visualization": {
          "emsField": "iso2",
          "emsLayerId": "world_countries",
          "layerId": "<UUID-LAYER>",
          "regionAccessor": "<UUID-REGION>",
          "valueAccessor": "<UUID-METRIC>"
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsChoropleth"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 12, "i": "<UUID-PANEL>", "w": 24, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "Events by Country",
  "type": "lens",
  "version": "8.11.0"
}
```

Common `emsLayerId` + `emsField` pairs:
- World countries: `"emsLayerId": "world_countries"`, `"emsField": "iso2"` (2-letter) or `"iso3"` (3-letter)
- US states: `"emsLayerId": "usa_states"`, `"emsField": "abbr"`

---

## 16. Gauge — Shape Variants

The gauge template in section 6 uses `"shape": "horizontalBullet"`. Available shapes:

| Shape name | Description |
|---|---|
| `horizontalBullet` | Linear horizontal progress bar (default, most common) |
| `verticalBullet` | Linear vertical progress bar |
| `arc` | Partial circular arc |
| `circle` | Full 360° circle gauge |

`ticksPosition` values: `"bands"` (colored bands, most common in real dashboards) or `"auto"`.

Add `goalAccessor` to set a target value line. Example with goal:

```json
"visualization": {
  "colorMode": "palette",
  "labelMajorMode": "auto",
  "layerId": "<UUID-LAYER>",
  "layerType": "data",
  "metricAccessor": "<UUID-METRIC>",
  "goalAccessor": "<UUID-GOAL>",
  "minAccessor": "<UUID-MIN>",
  "maxAccessor": "<UUID-MAX>",
  "shape": "arc",
  "ticksPosition": "bands"
}
```

---

## 17. Metric — Advanced Configuration

Verified against real integration dashboards. Extends section 4 with breakdown tiles and progress bar.

**Breakdown tiles** (one tile per category value):
```json
"visualization": {
  "breakdownByAccessor": "<UUID-BREAKDOWN>",
  "layerId": "<UUID-LAYER>",
  "layerType": "data",
  "maxAccessor": "<UUID-MAX>",
  "maxCols": 4,
  "metricAccessor": "<UUID-METRIC>",
  "progressDirection": "horizontal",
  "showBar": true,
  "palette": {
    "name": "status",
    "type": "palette",
    "params": {
      "continuity": "all",
      "name": "status",
      "progression": "fixed",
      "rangeMax": null,
      "rangeMin": null,
      "rangeType": "number",
      "reverse": false,
      "steps": 3,
      "stops": [
        { "color": "#209280", "stop": 0.59 },
        { "color": "#d6bf57", "stop": 1.18 },
        { "color": "#cc5642", "stop": 1.77 }
      ]
    }
  }
}
```

- `breakdownByAccessor` — `terms` bucket column UUID; splits into multiple tiles
- `maxAccessor` — `static_value` or `max` column for the progress bar max
- `showBar` / `progressDirection` — renders a progress bar background per tile
- `maxCols` — tiles per row

**lnsLegacyMetric** — older single-value metric still found in many dashboards. Simpler but has fewer features. Use `lnsMetric` for new dashboards; only use this when copying existing patterns:

```json
"visualization": {
  "accessor": "<UUID-METRIC>",
  "layerId": "<UUID-LAYER>",
  "layerType": "data",
  "size": "xl",
  "textAlign": "center",
  "titlePosition": "bottom"
}
```
Column for lnsLegacyMetric does NOT need `"params": { "emptyAsNull": true }` — just `operationType`, `sourceField`, `dataType`, `isBucketed`, `label`, `scale`.

---

## 18. Markdown / Text Panel

Use for: headers, section labels, instructions, contextual notes. Supports GitHub Flavored Markdown including links, images, and tables. Verified against real integration dashboards.

```json
{
  "embeddableConfig": {
    "enhancements": {
      "dynamicActions": {
        "events": []
      }
    },
    "savedVis": {
      "data": {
        "aggs": [],
        "searchSource": {
          "filter": [],
          "query": { "language": "kuery", "query": "" }
        }
      },
      "description": "",
      "params": {
        "fontSize": 12,
        "markdown": "## Section Header\n\nAdd context or instructions here.\n\nSupports **GitHub Flavored Markdown** including [links](/app/integrations) and tables.",
        "openLinksInNewTab": false
      },
      "title": "",
      "type": "markdown",
      "uiState": {}
    },
    "title": "<Optional panel title>"
  },
  "gridData": { "h": 6, "i": "<UUID-PANEL>", "w": 12, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "type": "visualization"
}
```

Note: `"type": "visualization"` at the panel level; `savedVis.type: "markdown"` inside. No `"version"` field needed. The `title` inside `embeddableConfig` (not `savedVis.title`) is what shows as the panel header.

---

## 19. ES|QL Visualization

Use for: charts driven by ES|QL queries instead of aggregation-based Lens. Useful when you need computed fields, JOIN-like behavior, or complex transformations not possible with standard aggregations.

ES|QL panels use the same `"type": "lens"` wrapper but with `"datasourceStates": { "textBased": { ... } }` instead of `"indexpattern"`:

```json
{
  "embeddableConfig": {
    "attributes": {
      "references": [],
      "state": {
        "datasourceStates": {
          "textBased": {
            "layers": {
              "<UUID-LAYER>": {
                "index": "<dataview-name>",
                "query": { "esql": "FROM logs-* | WHERE data_stream.dataset == \"<package>.<stream>\" | STATS count = COUNT(*) BY event.category | SORT count DESC | LIMIT 10" },
                "columns": [
                  { "id": "event.category", "meta": { "type": "string" } },
                  { "id": "count", "meta": { "type": "number" } }
                ]
              }
            }
          }
        },
        "filters": [],
        "query": { "language": "esql", "query": "" },
        "visualization": {
          "layers": [
            {
              "layerId": "<UUID-LAYER>",
              "layerType": "data",
              "seriesType": "bar_stacked",
              "xAccessor": "event.category",
              "accessors": ["count"]
            }
          ],
          "preferredSeriesType": "bar_stacked",
          "legend": { "isVisible": true, "position": "right" },
          "valueLabels": "hide",
          "fittingFunction": "None",
          "axisTitlesVisibilitySettings": { "x": true, "yLeft": true, "yRight": true },
          "gridlinesVisibilitySettings": { "x": true, "yLeft": true, "yRight": true },
          "tickLabelsVisibilitySettings": { "x": true, "yLeft": true, "yRight": true }
        }
      },
      "title": "",
      "type": "lens",
      "visualizationType": "lnsXY"
    },
    "enhancements": {},
    "hidePanelTitles": false
  },
  "gridData": { "h": 12, "i": "<UUID-PANEL>", "w": 24, "x": 0, "y": 0 },
  "panelIndex": "<UUID-PANEL>",
  "title": "ES|QL Chart",
  "type": "lens",
  "version": "8.11.0"
}
```

---

## UUID generation

Generate all UUIDs with `python3 -c "import uuid; print(uuid.uuid4())"` or use any UUID v4 generator. Every UUID in a dashboard file must be unique — never reuse a UUID between different panels.
