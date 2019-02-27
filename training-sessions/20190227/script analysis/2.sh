#!/usr/bin/env bash

#!/bin/bash
# ubuntu Auto install following
# Prometueus & Node exporter
# grafana

PROM_VER="2.0.0"
NODE_EXPORTER_VER="0.15.1"
GRAFANA_VER="5.4.2"



function install_pre(){
  apt-get update -y
  apt-get install -y adduser libfontconfig apt-transport-https systemd git
}
function install_go(){
  wget https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
  tar -C /usr/local -xzf go*.tar.gz
  echo -e "\nexport PATH=$PATH:/usr/local/go/bin" >> /etc/profile
}
function install_prom(){
  useradd --no-create-home --shell /bin/false prometheus
  mkdir /etc/prometheus
  mkdir /var/lib/prometheus
  chown prometheus:prometheus /etc/prometheus
  chown prometheus:prometheus /var/lib/prometheus
  curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz
  tar xvf prometheus-*.linux-amd64.tar.gz
  cp prometheus-*.linux-amd64/prometheus /usr/local/bin/
  cp prometheus-*.linux-amd64/promtool /usr/local/bin/
  cp -r prometheus-*.linux-amd64/consoles /etc/prometheus     #added
  cp -r prometheus-*.linux-amd64/console_libraries /etc/prometheus #added
  chown -R prometheus:prometheus /etc/prometheus/consoles
  chown -R prometheus:prometheus /etc/prometheus/console_libraries
  cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF



  cat <<EOF >> /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
remote_write:
  - url: "http://localhost:9201/write"
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
EOF
  systemctl daemon-reload
  systemctl enable prometheus
  systemctl start prometheus
  systemctl status prometheus
}

function install_nodeExporter(){
  useradd --no-create-home --shell /bin/false node_exporter
  curl -LO https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VER}/node_exporter-${NODE_EXPORTER_VER}.linux-amd64.tar.gz
  tar xvf node_exporter-0.15.1.linux-amd64.tar.gz
  cp node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
  chown node_exporter:node_exporter /usr/local/bin/node_exporter
  rm -rf node_exporter-0.15.1.linux-amd64.tar.gz node_exporter-0.15.1.linux-amd64
  cat << EOF >  /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable node_exporter
  systemctl start node_exporter
  systemctl status node_exporter


}

function install_graphite(){

  echo "graphite-carbon graphite-carbon/postrm_remove_databases boolean false" | sudo debconf-set-selections
  apt-get install python-dev ruby-dev bundler build-essential libpcre3-dev graphite-carbon graphite-web -y
  echo "CARBON_CACHE_ENABLED=true" > /etc/default/graphite-carbon
  sudo /usr/bin/graphite-build-search-index
  sudo /etc/init.d/carbon-cache start
  wget https://projects.unbit.it/downloads/uwsgi-latest.tar.gz
  tar xvf uwsgi-latest.tar.gz && cd uwsgi-*/
  python uwsgiconfig.py --build core
  python uwsgiconfig.py --plugin plugins/python core
  python uwsgiconfig.py --plugin plugins/rack core
  python uwsgiconfig.py --plugin plugins/carbon core
  sudo mkdir /etc/uwsgi
  sudo mkdir /usr/lib/uwsgi
  sudo cp uwsgi /usr/bin/uwsgi
  sudo cp python_plugin.so /usr/lib/uwsgi
  sudo cp rack_plugin.so /usr/lib/uwsgi
  sudo cp carbon_plugin.so /usr/lib/uwsgi
  cat <<EOF >> /etc/init/emperor.conf
# Emperor uWSGI script

description "uWSGI Emperor"
start on runlevel [2345]
stop on runlevel [06]

exec /usr/bin/uwsgi --emperor /etc/uwsgi
EOF
  start emperor
  graphite-manage syncdb --noinput
  chmod 777 /var/lib/graphite/graphite.db
  cat <<EOF >> /etc/uwsgi/graphite.ini
[uwsgi]
plugins-dir = /usr/lib/uwsgi
plugins = python
uid = _graphite
gid = _graphite
wsgi-file = /usr/share/graphite-web/graphite.wsgi
http-socket = :8080
EOF
}

function install_storageGW(){
  export PATH=$PATH:/usr/local/go/bin
  go get github.com/prometheus/prometheus/documentation/examples/remote_storage/remote_storage_adapter
  cp ~/go/bin/remote_storage_adapter /usr/local/bin/remote_storage_adapter
  cat << EOF >  /etc/systemd/system/remote_storage_adapter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/remote_storage_adapter  --graphite-address=localhost:2003

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable remote_storage_adapter
  systemctl start remote_storage_adapter
  systemctl status remote_storage_adapter
}

function install_grafana(){
  wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VER}_amd64.deb
  dpkg -i grafana_${GRAFANA_VER}_amd64.deb
  /usr/sbin/grafana-cli plugins install grafana-piechart-panel
  /usr/sbin/grafana-cli plugins install briangann-gauge-panel
  /usr/sbin/grafana-cli plugins install jdbranham-diagram-panel
  cat << EOF >/etc/grafana/provisioning/datasources/datasource.yaml
# config file version
apiVersion: 1
deleteDatasources:
  - name: Graphite
    orgId: 1
datasources:
  - name: Graphite
    type: graphite
    access: proxy
    url: http://localhost:8080
    jsonData:
      graphiteVersion: "1.1"
    editable: true
EOF
  cat << EOF >/etc/grafana/provisioning/dashboards/dashboard.yaml
# config file version
apiVersion: 1

providers:
- name: 'default'
  orgId: 1
  folder: ''
  type: file
  disableDeletion: false
  updateIntervalSeconds: 10 #how often Grafana will scan for changed dashboards
  options:
    path: /var/lib/grafana/dashboards
EOF
  mkdir -p /var/lib/grafana/dashboards
  cat << EOF >/var/lib/grafana/dashboards/nodeExporter.jsonvagr
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": 1860,
  "graphTooltip": 0,
  "id": 6,
  "links": [],
  "panels": [
    {
      "collapsed": false,
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 0
      },
      "id": 261,
      "panels": [],
      "repeat": null,
      "title": "Basic CPU / Mem / Disk Gauge",
      "type": "row"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": true,
      "colors": [
        "rgba(50, 172, 45, 0.97)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(245, 54, 54, 0.9)"
      ],
      "datasource": "Graphite",
      "decimals": null,
      "description": "Busy state of all CPU cores together",
      "format": "percent",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 0,
        "y": 1
      },
      "id": 20,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 2,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": true
      },
      "tableColumn": "",
      "targets": [
        {
          "refCount": 0,
          "refId": "A",
          "target": "asPercent(sumSeries(node_cpu.cpu.*.*.*.*.*.*.{system,wait,user}),sumSeries(node_cpu.cpu.*.*.*.*.*.*.*))",
          "textEditor": true
        },
        {
          "refCount": 0,
          "refId": "B",
          "target": ""
        }
      ],
      "thresholds": "85,95",
      "title": "CPU Busy",
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": true,
      "colors": [
        "rgba(50, 172, 45, 0.97)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(245, 54, 54, 0.9)"
      ],
      "datasource": "Graphite",
      "decimals": 0,
      "description": "Non available RAM memory",
      "format": "percent",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 4,
        "y": 1
      },
      "hideTimeOverride": false,
      "id": 16,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 4,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": true
      },
      "tableColumn": "",
      "targets": [
        {
          "hide": false,
          "refCount": 0,
          "refId": "A",
          "target": "divideSeries(diffSeries(sumSeries(node_memory_MemTotal.*.*.*.*) ,sumSeries(node_memory_MemFree.*.*.*.*)),sumSeries(node_memory_MemTotal.*.*.*.*))",
          "textEditor": true
        }
      ],
      "thresholds": "80,90",
      "title": "Used RAM Memory",
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": true,
      "colors": [
        "rgba(50, 172, 45, 0.97)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(245, 54, 54, 0.9)"
      ],
      "datasource": "Graphite",
      "decimals": null,
      "description": "Used Swap",
      "format": "percent",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 8,
        "y": 1
      },
      "id": 21,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 4,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": true
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "((node_memory_SwapTotal_bytes{instance=~\"$node:$port\",job=~\"$job\"} - node_memory_SwapFree_bytes{instance=~\"$node:$port\",job=~\"$job\"}) / (node_memory_SwapTotal_bytes{instance=~\"$node:$port\",job=~\"$job\"} )) * 100",
          "format": "time_series",
          "hide": false,
          "intervalFactor": 1,
          "refCount": 0,
          "refId": "A",
          "step": 900,
          "target": "divideSeries(sumSeries(node_memory_SwapCached.*.*.*.*),sumSeries(node_memory_SwapTotal.*.*.*.*))",
          "textEditor": true
        }
      ],
      "thresholds": "10,25",
      "title": "Used SWAP",
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": true,
      "colors": [
        "rgba(50, 172, 45, 0.97)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(245, 54, 54, 0.9)"
      ],
      "datasource": "Graphite",
      "decimals": null,
      "description": "Used Root FS",
      "format": "percent",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 12,
        "y": 1
      },
      "id": 154,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 4,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": true
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "",
          "format": "time_series",
          "hide": true,
          "intervalFactor": 1,
          "refCount": 1,
          "refId": "A",
          "step": 900,
          "target": "sumSeries(node_filesystem_size.*.rootfs.*.*.*.*.*.*.*.*)",
          "textEditor": false
        },
        {
          "refCount": 0,
          "refId": "B",
          "target": "divideSeries(sumSeries(node_filesystem_avail.*.rootfs.fstype.*.instance.*.*.*.*.*), #A)",
          "targetFull": "divideSeries(sumSeries(node_filesystem_avail.*.rootfs.fstype.*.instance.*.*.*.*.*), sumSeries(node_filesystem_size.*.rootfs.*.*.*.*.*.*.*.*))",
          "textEditor": false
        },
        {
          "hide": true,
          "refCount": 1,
          "refId": "C",
          "target": ""
        }
      ],
      "thresholds": "80,90",
      "title": "Used Root FS",
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": true,
      "colors": [
        "rgba(50, 172, 45, 0.97)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(245, 54, 54, 0.9)"
      ],
      "datasource": "Graphite",
      "decimals": null,
      "description": "Busy state of all CPU cores together (1 min average)",
      "format": "percent",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 16,
        "y": 1
      },
      "id": 19,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 2,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": true
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "avg(node_load1{}) /  count(count(node_cpu{}) by (cpu)) * 100",
          "format": "time_series",
          "hide": false,
          "intervalFactor": 1,
          "refId": "A",
          "step": 900,
          "target": "node_load1.instance.*.*.*",
          "textEditor": false
        }
      ],
      "thresholds": "85, 95",
      "title": "CPU System Load (1m avg)",
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": true,
      "colors": [
        "rgba(50, 172, 45, 0.97)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(245, 54, 54, 0.9)"
      ],
      "datasource": "Graphite",
      "decimals": null,
      "description": "Busy state of all CPU cores together (5 min average)",
      "format": "percent",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 20,
        "y": 1
      },
      "id": 155,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 2,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": true
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "avg(node_load5{instance=~\"$node:$port\",job=~\"$job\"}) /  count(count(node_cpu_seconds_total{instance=~\"$node:$port\",job=~\"$job\"}) by (cpu)) * 100",
          "format": "time_series",
          "hide": false,
          "intervalFactor": 1,
          "refId": "A",
          "step": 900,
          "target": "node_load5.*.localhost:9100.*.*"
        }
      ],
      "thresholds": "85, 95",
      "title": "CPU System Load (5m avg)",
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "collapsed": false,
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 5
      },
      "id": 262,
      "panels": [],
      "repeat": null,
      "title": "Basic CPU / Mem / Disk Info",
      "type": "row"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": false,
      "colors": [
        "rgba(245, 54, 54, 0.9)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(50, 172, 45, 0.97)"
      ],
      "datasource": "Graphite",
      "description": "Total number of CPU cores",
      "format": "short",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 0,
        "y": 6
      },
      "id": 14,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 4,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "count(count(node_cpu{}) by (cpu))",
          "format": "time_series",
          "hide": false,
          "intervalFactor": 1,
          "refId": "A",
          "step": 900,
          "target": "countSeries(node_cpu.cpu.*.instance.*.*.*.*.user)"
        }
      ],
      "thresholds": "",
      "title": "CPU Cores",
      "type": "singlestat",
      "valueFontSize": "50%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": false,
      "colors": [
        "rgba(245, 54, 54, 0.9)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(50, 172, 45, 0.97)"
      ],
      "datasource": "Graphite",
      "decimals": 2,
      "description": "Total RAM",
      "format": "bytes",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 4,
        "y": 6
      },
      "id": 75,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 4,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "70%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "node_memory_MemTotal{}",
          "format": "time_series",
          "intervalFactor": 1,
          "refId": "A",
          "step": 900,
          "target": "node_memory_MemTotal.*.*.*.*"
        }
      ],
      "thresholds": "",
      "title": "Total RAM",
      "type": "singlestat",
      "valueFontSize": "50%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": false,
      "colors": [
        "rgba(245, 54, 54, 0.9)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(50, 172, 45, 0.97)"
      ],
      "datasource": "Graphite",
      "decimals": 2,
      "description": "Total SWAP",
      "format": "bytes",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 8,
        "y": 6
      },
      "id": 18,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 4,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "70%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "node_memory_SwapTotal{}",
          "format": "time_series",
          "intervalFactor": 1,
          "refId": "A",
          "step": 900,
          "target": "node_memory_SwapTotal.*.*.*.*"
        }
      ],
      "thresholds": "",
      "title": "Total SWAP",
      "type": "singlestat",
      "valueFontSize": "50%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": false,
      "colors": [
        "rgba(50, 172, 45, 0.97)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(245, 54, 54, 0.9)"
      ],
      "datasource": "Graphite",
      "decimals": null,
      "description": "Total RootFS",
      "format": "bytes",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 12,
        "y": 6
      },
      "id": 23,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 4,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "node_filesystem_size{mountpoint=\"/\",fstype!=\"rootfs\"}",
          "format": "time_series",
          "hide": false,
          "intervalFactor": 1,
          "refId": "A",
          "step": 900,
          "target": "node_filesystem_size.*.rootfs.fstype.rootfs.*.*.*.*.*.*",
          "textEditor": true
        }
      ],
      "thresholds": "70,90",
      "title": "Total RootFS",
      "type": "singlestat",
      "valueFontSize": "50%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": false,
      "colors": [
        "rgba(245, 54, 54, 0.9)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(50, 172, 45, 0.97)"
      ],
      "datasource": "Graphite",
      "decimals": 2,
      "description": "System Load (1m avg)",
      "format": "short",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 16,
        "y": 6
      },
      "id": 17,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "minSpan": 2,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "",
          "format": "time_series",
          "hide": false,
          "intervalFactor": 1,
          "refId": "A",
          "step": 900,
          "target": "node_load1.*.*.*.*",
          "textEditor": false
        }
      ],
      "thresholds": "",
      "title": "System Load (1m avg)",
      "type": "singlestat",
      "valueFontSize": "50%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorValue": false,
      "colors": [
        "rgba(245, 54, 54, 0.9)",
        "rgba(237, 129, 40, 0.89)",
        "rgba(50, 172, 45, 0.97)"
      ],
      "datasource": "Graphite",
      "decimals": 1,
      "description": "System uptime",
      "format": "ms",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 20,
        "y": 6
      },
      "hideTimeOverride": true,
      "id": 15,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "nullPointMode": "null",
      "nullText": null,
      "postfix": "s",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "",
          "format": "time_series",
          "hide": false,
          "intervalFactor": 2,
          "refCount": 0,
          "refId": "A",
          "step": 1800,
          "target": "node_boot_time.*.*.*.*",
          "textEditor": true
        }
      ],
      "thresholds": "",
      "title": "Uptime",
      "transparent": false,
      "type": "singlestat",
      "valueFontSize": "50%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    }
  ],
  "refresh": false,
  "schemaVersion": 16,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-24h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
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
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "timezone": "browser",
  "title": "Node Exporter Full",
  "uid": "2ZvrNxrmk",
  "version": 4
}
EOF
  service grafana-server start
}

function main(){
    install_pre
    install_go
    install_prom
    install_nodeExporter
    install_graphite
    install_storageGW
    install_grafana
}
main