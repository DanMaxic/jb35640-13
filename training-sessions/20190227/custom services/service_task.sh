#!/usr/bin/env bash

#getting the util from the internet:

curl -LO https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VER}/node_exporter-${NODE_EXPORTER_VER}.linux-amd64.tar.gz
tar xvf node_exporter-0.15.1.linux-amd64.tar.gz
cp node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-0.15.1.linux-amd64.tar.gz node_exporter-0.15.1.linux-amd64

#command to execute:
/usr/local/bin/node_exporter