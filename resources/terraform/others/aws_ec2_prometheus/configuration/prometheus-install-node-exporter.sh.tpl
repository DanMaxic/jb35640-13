#!/bin/bash -x

set -e

#global variables
install_base_dir=/opt/prometheus
data_base_dir=/data/prometheus

function install_node_exporter() {
add_user_and_group

node_exporter_version=0.16.0
data_dir=${data_base_dir}/node_exporter

cd $(mktemp -d)
wget -q https://github.com/prometheus/node_exporter/releases/download/v${node_exporter_version}/node_exporter-${node_exporter_version}.linux-amd64.tar.gz
node_exporter_dir=${install_base_dir}/node_exporter
mkdir -p ${node_exporter_dir}
tar -zxf node_exporter-${node_exporter_version}.linux-amd64.tar.gz --strip-components=1 -C ${node_exporter_dir}
mkdir -p ${data_dir}
chown -R prometheus.prometheus ${data_base_dir} ${install_base_dir}
}

function add_user_and_group() {
getent group prometheus >/dev/null || sudo groupadd -r prometheus
getent passwd prometheus >/dev/null || \
useradd -r -g prometheus -d ${install_base_dir} -s /sbin/nologin \
        -c "Prometheus services" prometheus
}

install_node_exporter
