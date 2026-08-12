# Домашнее задание к занятию 14 «Средство визуализации Grafana»

## 1. Самостоятельно разверните grafana, где в роли источника данных будет выступать prometheus, а сборщиком данных будет node-exporter.

### Data sourese
![Data sourse](https://github.com/user-attachments/assets/8682adcf-d8f7-4cc6-8d6a-402e7fec133d)

## 2. Создание Dashboard

### Dashboard
![Dashboard](https://github.com/user-attachments/assets/702511ed-68fe-4500-b9ce-6fb1d1d63b17)

### Утилизация CPU

>promql-запрос
>```text
>100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
>```

### Load Average 1/5/15

>promql-запрос
>```text
>node_load1
>node_load5
>node_load15
>```

### Свободная оперативная память

>promql-запрос
>```text
>node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
>```

### Свободное место на файловой системе

>promql-запрос
>```text
>node_filesystem_avail_bytes{mountpoint="/"} / 1024 / 1024 / 1024
>```

## 3. Создать Alerts

### Alerts

![Alerts](https://github.com/user-attachments/assets/fca7229f-ad38-4627-9f6e-c2b30a29addc)

### Test alert message

![Test alert message](https://github.com/user-attachments/assets/3296adab-2716-458b-b14d-855183a69407)

## 4. Сохранить JSON MODEL

<details>
  
<summary>
  
### JSON MODEL

</summary>   

{
  "annotations": [
    {
      "kind": "AnnotationQuery",
      "spec": {
        "builtIn": true,
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "query": {
          "datasource": {
            "name": "-- Grafana --"
          },
          "group": "grafana",
          "kind": "DataQuery",
          "spec": {},
          "version": "v0"
        }
      }
    }
  ],
  "cursorSync": "Off",
  "editable": true,
  "elements": {
    "panel-2": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "ffuwvxrhxyneoa"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "editorMode": "code",
                      "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[1m])) * 100)",
                      "legendFormat": "__auto",
                      "range": true
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 2,
        "links": [],
        "title": "Утилизация CPU",
        "vizConfig": {
          "group": "gauge",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "max": 100,
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "percent"
              },
              "overrides": []
            },
            "options": {
              "barShape": "flat",
              "barWidthFactor": 0.3,
              "effects": {
                "barGlow": false,
                "centerGlow": false,
                "gradient": true
              },
              "endpointMarker": "point",
              "minVizHeight": 75,
              "minVizWidth": 75,
              "orientation": "auto",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "segmentCount": 1,
              "segmentSpacing": 0.3,
              "shape": "gauge",
              "showThresholdLabels": false,
              "showThresholdMarkers": false,
              "sizing": "auto",
              "sparkline": true,
              "textMode": "auto"
            }
          },
          "version": "13.1.3"
        }
      }
    },
    "panel-3": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "ffuwvxrhxyneoa"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "editorMode": "code",
                      "expr": "node_load1",
                      "legendFormat": "Load Average за 1 минуту",
                      "range": true
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              },
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "ffuwvxrhxyneoa"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "editorMode": "code",
                      "exemplar": true,
                      "expr": "node_load5",
                      "instant": false,
                      "legendFormat": "Load Average за 5 минут",
                      "range": true
                    },
                    "version": "v0"
                  },
                  "refId": "B"
                }
              },
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "ffuwvxrhxyneoa"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "editorMode": "code",
                      "expr": "node_load15",
                      "instant": false,
                      "legendFormat": "Load Average за 15 минут",
                      "range": true
                    },
                    "version": "v0"
                  },
                  "refId": "C"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 3,
        "links": [],
        "title": "Load Average 1/5/15",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 25,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "linear",
                  "lineWidth": 1,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "auto",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "percent"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                }
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [],
                "displayMode": "list",
                "enableFacetedFilter": false,
                "overflow": "ellipsis",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "single",
                "sort": "none"
              }
            }
          },
          "version": "13.1.3"
        }
      }
    },
    "panel-4": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "ffuwvxrhxyneoa"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "editorMode": "code",
                      "expr": "node_memory_MemAvailable_bytes / 1024 / 1024 / 1024",
                      "legendFormat": "__auto",
                      "range": true
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 4,
        "links": [],
        "title": "Свободная оперативная память",
        "vizConfig": {
          "group": "gauge",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "thresholds": {
                  "mode": "percentage",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "#EAB839",
                      "value": 60
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "gbytes"
              },
              "overrides": []
            },
            "options": {
              "barShape": "flat",
              "barWidthFactor": 0.54,
              "effects": {
                "barGlow": false,
                "centerGlow": false,
                "gradient": false
              },
              "endpointMarker": "point",
              "minVizHeight": 75,
              "minVizWidth": 75,
              "orientation": "auto",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "segmentCount": 1,
              "segmentSpacing": 0.3,
              "shape": "gauge",
              "showThresholdLabels": false,
              "showThresholdMarkers": true,
              "sizing": "auto",
              "sparkline": true,
              "textMode": "auto"
            }
          },
          "version": "13.1.3"
        }
      }
    },
    "panel-5": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "ffuwvxrhxyneoa"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "editorMode": "code",
                      "expr": "node_filesystem_avail_bytes{mountpoint=\"/\"} / 1024 / 1024 / 1024",
                      "legendFormat": "__auto",
                      "range": true
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 5,
        "links": [],
        "title": "Свободное место на файловой системе",
        "vizConfig": {
          "group": "gauge",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "continuous-GrYlRd"
                },
                "thresholds": {
                  "mode": "percentage",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "#EAB839",
                      "value": 40
                    },
                    {
                      "color": "red",
                      "value": 60
                    }
                  ]
                },
                "unit": "decgbytes"
              },
              "overrides": []
            },
            "options": {
              "barShape": "flat",
              "barWidthFactor": 0.54,
              "effects": {
                "barGlow": false,
                "centerGlow": false,
                "gradient": true
              },
              "endpointMarker": "point",
              "minVizHeight": 75,
              "minVizWidth": 75,
              "orientation": "auto",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "segmentCount": 1,
              "segmentSpacing": 0.3,
              "shape": "gauge",
              "showThresholdLabels": false,
              "showThresholdMarkers": true,
              "sizing": "auto",
              "sparkline": true,
              "textMode": "auto"
            }
          },
          "version": "13.1.3"
        }
      }
    }
  },
  "layout": {
    "kind": "GridLayout",
    "spec": {
      "items": [
        {
          "kind": "GridLayoutItem",
          "spec": {
            "element": {
              "kind": "ElementReference",
              "name": "panel-2"
            },
            "height": 8,
            "width": 12,
            "x": 0,
            "y": 0
          }
        },
        {
          "kind": "GridLayoutItem",
          "spec": {
            "element": {
              "kind": "ElementReference",
              "name": "panel-3"
            },
            "height": 8,
            "width": 12,
            "x": 12,
            "y": 0
          }
        },
        {
          "kind": "GridLayoutItem",
          "spec": {
            "element": {
              "kind": "ElementReference",
              "name": "panel-4"
            },
            "height": 8,
            "width": 12,
            "x": 0,
            "y": 8
          }
        },
        {
          "kind": "GridLayoutItem",
          "spec": {
            "element": {
              "kind": "ElementReference",
              "name": "panel-5"
            },
            "height": 8,
            "width": 12,
            "x": 12,
            "y": 8
          }
        }
      ]
    }
  },
  "links": [],
  "liveNow": false,
  "preferences": {
    "layout": {
      "kind": "GridLayout",
      "spec": {
        "items": []
      }
    }
  },
  "preload": false,
  "tags": [],
  "timeSettings": {
    "autoRefresh": "",
    "autoRefreshIntervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "fiscalYearStartMonth": 0,
    "from": "now-6h",
    "hideTimepicker": false,
    "timezone": "browser",
    "to": "now"
  },
  "title": "Monitoring",
  "variables": []
}

</details>
