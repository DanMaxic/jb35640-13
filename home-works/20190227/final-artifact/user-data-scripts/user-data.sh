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

function main(){
    install_pre
    install_go
    install_prom
    install_nodeExporter
    install_graphite
    install_storageGW
}
main