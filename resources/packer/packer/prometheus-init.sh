#!/bin/bash -x
set -e
install_base_dir=/opt/prometheus
data_base_dir=/data/prometheus
region=eu-west-3

function get_prereqs(){
  sudo apt-get update && \
  sudo apt-get install unzip python-pip python-dev openjdk-9-jre-headless ntp docker.io -y
  sudo /bin/systemctl enable ntp
  sudo pip install awscli
}


function install_grafana(){
  grafana_version=6.0.2
  sudo wget https://dl.grafana.com/oss/release/grafana_${grafana_version}_amd64.deb
  sudo apt-get install -y adduser libfontconfig
  sudo dpkg -i grafana_${grafana_version}_amd64.deb
}

function install_prometheus(){
  prometheus_version=2.8.0
  cd $(mktemp -d)
  wget https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-amd64.tar.gz
  sudo mkdir -p ${install_base_dir}
  sudo tar -zxf prometheus-${prometheus_version}.linux-amd64.tar.gz --strip-components=1 -C ${install_base_dir}
  sudo chown -R prometheus:prometheus ${install_base_dir}
}


function install_node_exporter(){

  node_exporter_version='0.17.0'
  node_exporter_dir=${install_base_dir}/node_exporter

  cd $(mktemp -d)
  wget https://github.com/prometheus/node_exporter/releases/download/v${node_exporter_version}/node_exporter-${node_exporter_version}.linux-amd64.tar.gz
  sudo mkdir -p ${node_exporter_dir}
  sudo tar -zxf node_exporter-${node_exporter_version}.linux-amd64.tar.gz --strip-components=1 -C ${node_exporter_dir}
}

function add_user_and_group(){
  getent group prometheus >/dev/null || sudo groupadd -r prometheus
  getent passwd prometheus >/dev/null || \
  sudo useradd -r -g prometheus -d ${install_base_dir} -s /sbin/nologin \
          -c "Prometheus services" prometheus
}

function install_cw_exporter(){
  cw_exporter_version="0.5.0"

  cd /opt/prometheus
  sudo wget --tries=2 http://search.maven.org/remotecontent?filepath=io/prometheus/cloudwatch/cloudwatch_exporter/${cw_exporter_version}/cloudwatch_exporter-${cw_exporter_version}-jar-with-dependencies.jar -O cloudwatch_exporter-${cw_exporter_version}-jar-with-dependencies.jar
  sudo chown prometheus.prometheus cloudwatch_exporter-${cw_exporter_version}-jar-with-dependencies.jar
}

function install_alertmgr(){
  alertmgr_ver="0.16.1"
  sudo mkdir -p ${install_base_dir}/alertmanager/{templates,alert_rules}
  sudo wget -q https://github.com/prometheus/alertmanager/releases/download/v${alertmgr_ver}/alertmanager-${alertmgr_ver}.linux-amd64.tar.gz
  sudo tar xvfz alertmanager-${alertmgr_ver}.linux-amd64.tar.gz --strip-components=1 -C ${install_base_dir}/alertmanager
  sudo chown -R prometheus:prometheus /${install_base_dir}/alertmanager
}

function install_es_exporter() {
  es_exporter_download_url="https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v1.0.3rc1/elasticsearch_exporter-1.0.3rc1.linux-amd64.tar.gz"
  sudo mkdir /opt/elasticsearch_exporter
  sudo adduser --shell /bin/false --no-create-home --disabled-password --disabled-login --gecos ElasticsearchExporter elasticexporter
  sudo wget -O /tmp/elasticsearch_exporter.tar.gz "${es_exporter_download_url}"
  sudo tar xvfz /tmp/elasticsearch_exporter.tar.gz --strip-components=1 -C /opt/elasticsearch_exporter/
  sudo rm -rf /tmp/elasticsearch_exporter*
}

function install_postgres_exporter() {
  pg_exp_ver="0.4.7"
  sudo wget -O /tmp/pg.tar.gz https://github.com/wrouesnel/postgres_exporter/releases/download/v${pg_exp_ver}/postgres_exporter_v${pg_exp_ver}_linux-amd64.tar.gz
  sudo tar xvfx /tmp/pg.tar.gz --strip-components=1 -C ${install_base_dir}
  sudo chown -R prometheus:prometheus ${install_base_dir}
  sudo rm -rf /tmp/pg.tar.gz
}

function install_kafka_exporter() {
  kafka_exporter_version="1.2.0"
  kafka_exporter_download_url="https://github.com/danielqsj/kafka_exporter/releases/download/v${kafka_exporter_version}/kafka_exporter-${kafka_exporter_version}.linux-amd64.tar.gz"
  sudo wget -O /tmp/kafka_exporter.tar.gz "${kafka_exporter_download_url}"
  sudo tar xvfz /tmp/kafka_exporter.tar.gz --strip-components=1 -C ${install_base_dir}
  sudo chown -R prometheus:prometheus ${install_base_dir}
  sudo rm -f /tmp/kafka_exporter*
}

function install_push_gateway() {
  push_gateway_version="0.7.0"
  push_gateway_download_url="https://github.com/prometheus/pushgateway/releases/download/v${push_gateway_version}/pushgateway-${push_gateway_version}.linux-amd64.tar.gz"
  sudo wget -O /tmp/push_gateway.tar.gz "${push_gateway_download_url}"
  sudo tar xvfz /tmp/push_gateway.tar.gz --strip-components=1 -C ${install_base_dir}
  sudo chown -R prometheus:prometheus ${install_base_dir}
  sudo rm -f /tmp/push_gateway*
}

#Main
get_prereqs
add_user_and_group
install_prometheus
install_node_exporter
install_cw_exporter
install_alertmgr
install_grafana
install_es_exporter
install_postgres_exporter
install_kafka_exporter
install_push_gateway

