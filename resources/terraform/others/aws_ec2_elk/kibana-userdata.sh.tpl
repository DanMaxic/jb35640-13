#!/bin/bash -x

function install_kibana(){

curl -s https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y kibana=${ek_version}
cat <<EOF | sudo tee /etc/kibana/kibana.yml
elasticsearch.url: "${es_url}"
server.host: 0.0.0.0
logging.dest: /tmp/kibana.log
EOF
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl restart kibana
}

function install_nodeexporter() {
cat << EOF > /lib/systemd/system/node_exporter.service
[Unit]
Description=Prometheus node exporter service
Documentation=None
After=network.target

[Service]
Restart=on-failure
RestartSec=30
RestartPreventExitStatus=5
SyslogIdentifier=node-exporter
ExecStartPre=-/bin/mkdir -p /opt/prometheus/node_exporter /data/prometheus
ExecStartPre=-/usr/sbin/groupadd -r prometheus
ExecStartPre=-/usr/sbin/useradd -r -g prometheus -d /opt/prometheus -s /sbin/nologin -c "Prometheus services" prometheus
ExecStartPre=-/usr/bin/wget -q "https://github.com/prometheus/node_exporter/releases/download/v0.15.2/node_exporter-0.15.2.linux-amd64.tar.gz"
ExecStartPre=-/bin/tar -zxf node_exporter-0.15.2.linux-amd64.tar.gz --strip-components=1 -C /opt/prometheus/node_exporter
ExecStartPre=-/bin/chown -R prometheus.prometheus /opt/prometheus /data/prometheus
ExecStart=/opt/prometheus/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo service node_exporter restart
}

install_kibana
install_nodeexporter
