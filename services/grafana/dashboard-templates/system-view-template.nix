{ id, hostname }: {
  annotations = {
    list = [
      {
        builtIn = 1;
        datasource = {
          type = "grafana";
          uid = "-- Grafana --";
        };
        enable = true;
        hide = true;
        iconColor = "rgba(0, 211, 255, 1)";
        name = "Annotations & Alerts";
        type = "dashboard";
      }
    ];
  };
  editable = true;
  fiscalYearStartMonth = 0;
  graphTooltip = 0;
  id = id;
  links = [ ];
  panels = [
    {
      collapsed = true;
      gridPos = {
        h = 1;
        w = 24;
        x = 0;
        y = 0;
      };
      id = 17;
      panels = [
        {
          datasource = {
            type = "loki";
            uid = "P982945308D3682D1";
          };
          gridPos = {
            h = 22;
            w = 16;
            x = 0;
            y = 1;
          };
          id = 14;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = false;
            showCommonLabels = false;
            showLabels = false;
            showTime = false;
            sortOrder = "Descending";
            wrapLogMessage = false;
          };
          targets = [
            {
              datasource = {
                type = "loki";
                uid = "P982945308D3682D1";
              };
              editorMode = "builder";
              expr = "{host=\"${hostname}\"} | json != `_SOURCE_REALTIME_TIMESTAMP` | line_format `{{__timestamp__ | date \"02 Jan 06 15:04 MST\"}} | {{alignLeft 8 .detected_level}} | {{.MESSAGE}}`";
              hide = false;
              queryType = "range";
              refId = "A";
            }
            {
              datasource = {
                type = "loki";
                uid = "P982945308D3682D1";
              };
              editorMode = "builder";
              expr = "{host=\"${hostname}\"} | json | label_format timestamp=_SOURCE_REALTIME_TIMESTAMP | timestamp != `` | line_format `{{.timestamp | unixToTime | date \"02 Jan 06 15:04 MST\" }} | {{alignLeft 8 .detected_level}} | {{.MESSAGE}}`";
              hide = false;
              queryType = "range";
              refId = "B";
            }
          ];
          title = "Journal";
          type = "logs";
        }
      ];
      title = "Logs";
      type = "row";
    }
    {
      collapsed = true;
      gridPos = {
        h = 1;
        w = 24;
        x = 0;
        y = 1;
      };
      id = 13;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 80;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 2;
            x = 0;
            y = 1;
          };
          id = 7;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            percentChangeColorMode = "standard";
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showPercentChange = false;
            textMode = "auto";
            wideLayout = true;
          };
          pluginVersion = "11.1.4";
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(device) (rate(node_disk_io_time_seconds_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "__auto";
              range = true;
              refId = "A";
              useBackend = false;
            }
          ];
          title = "io time";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 80;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 4;
            x = 2;
            y = 1;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            percentChangeColorMode = "standard";
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showPercentChange = false;
            textMode = "auto";
            wideLayout = true;
          };
          pluginVersion = "11.1.4";
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(hostname) (rate(node_pressure_io_stalled_seconds_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "time stalled";
              range = true;
              refId = "A";
              useBackend = false;
            }
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(hostname) (rate(node_pressure_io_waiting_seconds_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              hide = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "time waiting";
              range = true;
              refId = "B";
              useBackend = false;
            }
          ];
          title = "io pressure";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 0;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                insertNulls = false;
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "auto";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 80;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 6;
            x = 6;
            y = 1;
          };
          id = 15;
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(device) (rate(node_disk_io_time_seconds_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              includeNullMetadata = true;
              legendFormat = "__auto";
              range = true;
              refId = "A";
              useBackend = false;
            }
          ];
          title = "IO Time";
          type = "timeseries";
        }
      ];
      title = "IO/Disk";
      type = "row";
    }
    {
      collapsed = true;
      gridPos = {
        h = 1;
        w = 24;
        x = 0;
        y = 2;
      };
      id = 12;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                fillOpacity = 80;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineWidth = 0;
                scaleDistribution = {
                  log = 2;
                  type = "symlog";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              mappings = [ ];
              max = 130000000;
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                ];
              };
              unit = "binBps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 2;
          };
          id = 5;
          options = {
            barRadius = 0;
            barWidth = 0.97;
            fullHighlight = false;
            groupWidth = 0.7;
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            orientation = "auto";
            showValue = "auto";
            stacking = "normal";
            tooltip = {
              mode = "single";
              sort = "none";
            };
            xTickLabelRotation = 0;
            xTickLabelSpacing = 100;
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(device) (rate(node_network_receive_bytes_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "__auto";
              range = true;
              refId = "A";
              useBackend = false;
            }
          ];
          title = "Network RX";
          type = "barchart";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                fillOpacity = 80;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineWidth = 0;
                scaleDistribution = {
                  log = 2;
                  type = "symlog";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              mappings = [ ];
              max = 130000000;
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                ];
              };
              unit = "binBps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 2;
          };
          id = 6;
          options = {
            barRadius = 0;
            barWidth = 0.97;
            fullHighlight = false;
            groupWidth = 0.7;
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            orientation = "auto";
            showValue = "auto";
            stacking = "normal";
            tooltip = {
              mode = "single";
              sort = "none";
            };
            xTickLabelRotation = 0;
            xTickLabelSpacing = 100;
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(device) (rate(node_network_transmit_bytes_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "__auto";
              range = true;
              refId = "A";
              useBackend = false;
            }
          ];
          title = "Network TX";
          type = "barchart";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 25;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                insertNulls = false;
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "auto";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 80;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 6;
            x = 0;
            y = 10;
          };
          id = 16;
          options = {
            legend = {
              calcs = [ ];
              displayMode = "hidden";
              placement = "right";
              showLegend = false;
            };
            tooltip = {
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "code";
              expr = "rate(emerald_city_torrent_alltime_dl_total{}[5m])";
              fullMetaSearch = false;
              includeNullMetadata = true;
              instant = false;
              legendFormat = "__auto";
              range = true;
              refId = "A";
              useBackend = false;
            }
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "code";
              expr = "-rate(emerald_city_torrent_alltime_ul_total{}[5m])";
              fullMetaSearch = false;
              hide = false;
              includeNullMetadata = true;
              instant = false;
              legendFormat = "__auto";
              range = true;
              refId = "B";
              useBackend = false;
            }
          ];
          title = "Emerald City Torrent Network Usage";
          type = "timeseries";
        }
      ];
      title = "Network";
      type = "row";
    }
    {
      collapsed = true;
      gridPos = {
        h = 1;
        w = 24;
        x = 0;
        y = 3;
      };
      id = 11;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 80;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 2;
            x = 0;
            y = 3;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            percentChangeColorMode = "standard";
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showPercentChange = false;
            textMode = "auto";
            wideLayout = true;
          };
          pluginVersion = "11.1.4";
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(hostname) (rate(node_pressure_cpu_waiting_seconds_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "time waiting";
              range = true;
              refId = "A";
              useBackend = false;
            }
          ];
          title = "cpu pressure";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 80;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 5;
            x = 2;
            y = 3;
          };
          id = 1;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            percentChangeColorMode = "standard";
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showPercentChange = false;
            textMode = "auto";
            wideLayout = true;
          };
          pluginVersion = "11.1.4";
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "code";
              expr = "avg by(hostname) (node_load1{hostname=\"${hostname}\"})";
              fullMetaSearch = false;
              includeNullMetadata = true;
              legendFormat = "1m";
              range = true;
              refId = "A";
              useBackend = false;
            }
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              editorMode = "code";
              expr = "avg by(hostname) (node_load5{hostname=\"${hostname}\"})";
              hide = false;
              instant = false;
              legendFormat = "5m";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              editorMode = "code";
              expr = "avg by(hostname) (node_load15{hostname=\"${hostname}\"})";
              hide = false;
              instant = false;
              legendFormat = "15m";
              range = true;
              refId = "C";
            }
          ];
          title = "Load Averages";
          type = "stat";
        }
      ];
      title = "CPU";
      type = "row";
    }
    {
      collapsed = true;
      gridPos = {
        h = 1;
        w = 24;
        x = 0;
        y = 4;
      };
      id = 10;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 80;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 4;
            x = 0;
            y = 5;
          };
          id = 2;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            percentChangeColorMode = "standard";
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showPercentChange = false;
            textMode = "auto";
            wideLayout = true;
          };
          pluginVersion = "11.1.4";
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(hostname) (rate(node_pressure_memory_stalled_seconds_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "time stalled";
              range = true;
              refId = "A";
              useBackend = false;
            }
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "builder";
              expr = "avg by(hostname) (rate(node_pressure_memory_waiting_seconds_total{hostname=\"${hostname}\"}[5m]))";
              fullMetaSearch = false;
              hide = false;
              includeNullMetadata = false;
              instant = false;
              legendFormat = "time waiting";
              range = true;
              refId = "B";
              useBackend = false;
            }
          ];
          title = "memory pressure";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 2;
            x = 4;
            y = 5;
          };
          id = 8;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            percentChangeColorMode = "standard";
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showPercentChange = false;
            textMode = "auto";
            wideLayout = true;
          };
          pluginVersion = "11.1.4";
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "code";
              expr = "avg by(job) (node_memory_MemTotal_bytes{hostname=\"${hostname}\", job=\"${hostname}-node\"} - node_memory_MemAvailable_bytes{hostname=\"${hostname}\", job=\"${hostname}-node\"})";
              fullMetaSearch = false;
              includeNullMetadata = true;
              instant = false;
              legendFormat = "Memory";
              range = true;
              refId = "A";
              useBackend = false;
            }
          ];
          title = "Free Memory";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "P1809F7CD0C75ACF3";
          };
          fieldConfig = {
            defaults = {
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 2;
            x = 6;
            y = 5;
          };
          id = 9;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            percentChangeColorMode = "standard";
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showPercentChange = false;
            textMode = "auto";
            wideLayout = true;
          };
          pluginVersion = "11.1.4";
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "P1809F7CD0C75ACF3";
              };
              disableTextWrap = false;
              editorMode = "code";
              expr = "delta(node_memory_MemAvailable_bytes{hostname=\"${hostname}\", job=\"${hostname}-node\"}[5m])";
              fullMetaSearch = false;
              includeNullMetadata = true;
              instant = false;
              legendFormat = "__auto";
              range = true;
              refId = "A";
              useBackend = false;
            }
          ];
          title = "Memory Velocity";
          type = "stat";
        }
      ];
      title = "Memory";
      type = "row";
    }
  ];
  refresh = "5s";
  schemaVersion = 39;
  tags = [ ];
  templating = {
    list = [ ];
  };
  time = {
    from = "now-6h";
    to = "now";
  };
  timepicker = { };
  timezone = "browser";
  title = "System View - ${hostname}";
  uid = "${hostname}";
  version = 18;
  weekStart = "";
}
