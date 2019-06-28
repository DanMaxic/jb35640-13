#!/bin/bash -x

set -e

#global variables
install_base_dir=/opt/prometheus
data_base_dir=/data/prometheus
IP=$(curl -q http://169.254.169.254/latest/dynamic/instance-identity/document|grep privateIp|awk -F\" '{print $4}')

function get_prereqs(){
apt-get update && \
apt-get install unzip python-pip python-dev openjdk-9-jre-headless -y
pip install awscli
}

function set_disks() {

dev="${device}"
dir="$${data_base_dir}"

INSTANCE_ID=$(ec2metadata --instance-id)
REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')

# block until prom persistent data disk was attached
until test -b $${dev} ;do
  VOLUME_ID=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$${INSTANCE_ID}" "Name=key,Values=ebs_volume_ids" --region $${REGION} --output=text | cut -f5)
  echo "Attempting to mount $${VOLUME_ID} to $${dev} on $${INSTANCE_ID}"
  aws ec2 attach-volume --volume-id $${VOLUME_ID} --device $${dev} --instance-id $${INSTANCE_ID} --region $${REGION} || true
  sleep 15
done

if mount | grep '/mnt' &>/dev/null ;then
  umount -f /mnt
fi

if [ -b "$${dev}" ] ; then
    mkdir -p $${dir}

    if ! file -sL $${dev} | grep ext4 ; then
      mkfs.ext4 $${dev} -L $(hostname)
    fi
    if ! grep -q "$${dev} $${dir}" "/etc/fstab" ; then
      sed -i '/\/mnt/d' /etc/fstab
      echo "$${dev} $${dir} ext4 noatime,nodiratime,data=writeback,nobh,delalloc 0 0" >> /etc/fstab
    fi
    mount -a
fi
}


function install_ntpd(){
sudo apt-get install -y ntp
sudo /bin/systemctl enable ntp
}


function install_grafana(){
grafana_version=5.2.2
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_$${grafana_version}_amd64.deb
sudo apt-get install -y adduser libfontconfig
sudo dpkg -i grafana_$${grafana_version}_amd64.deb
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sed -i '/^\[database\]/d' /etc/grafana/grafana.ini
cat << EOF >>/etc/grafana/grafana.ini
[database]
url=mysql://admin:${grafana_admin_password}@${grafana_db_endpoint}/grafana
EOF
}


function install_ecs_exporter(){
#sudo apt-get install golang-1.9-go -y
#sudo ln -s /usr/lib/go-1.9/bin/go /usr/bin/go
#mkdir -p /tmp/ecs_exporter
#GOPATH=/go go get -u github.com/teralytics/prometheus-ecs-discovery
#mv /go/bin/prometheus-ecs-discovery $${install_base_dir}/prometheus-ecs-discovery
wget "https://github.com/teralytics/prometheus-ecs-discovery/releases/download/v0.5.0/prometheus-ecs-discovery-linux-amd64" -O $${install_base_dir}/prometheus-ecs-discovery
chmod +x $${install_base_dir}/prometheus-ecs-discovery
mkdir -p $${data_base_dir}/ecs
chown -R prometheus.prometheus $${data_base_dir}/ecs $${install_base_dir}/prometheus-ecs-discovery

cat << EOF > /lib/systemd/system/prometheus-ecs-discovery.service
[Unit]
Description=Prometheus ecs discovery
Documentation=https://prometheus.io
After=network.target

[Service]
Environment=AWS_REGION=${aws_region}
User=prometheus
WorkingDirectory=$${install_base_dir}
ExecStart=/opt/prometheus/prometheus-ecs-discovery -config.write-to $${install_base_dir}/ecs_file_sd.yml
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemd_enable prometheus-ecs-discovery
}

function install_springboot_discovery(){
wget "https://github.com/Pucster/prometheus-springboot-actuator-ecs-discovery/releases/download/v0.0.1/prometheus-springboot-actuator-ecs-discovery" -O $${install_base_dir}/prometheus-springboot-actuator-ecs-discovery
chmod +x $${install_base_dir}/prometheus-springboot-actuator-ecs-discovery
chown -R prometheus.prometheus $${install_base_dir}/prometheus-springboot-actuator-ecs-discovery

cat << EOF > /lib/systemd/system/prometheus-springboot-actuator-ecs-discovery.service
[Unit]
Description=Prometheus ECS springboot discovery
Documentation=https://prometheus.io
After=network.target

[Service]
Environment=AWS_REGION=${aws_region}
User=prometheus
WorkingDirectory=$${install_base_dir}
ExecStart=/opt/prometheus/prometheus-springboot-actuator-ecs-discovery -config.write-to $${install_base_dir}/ecs_springboot.yml
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemd_enable prometheus-springboot-actuator-ecs-discovery
}

function install_prometheus(){
add_user_and_group

prometheus_version=2.3.2
data_dir=$${data_base_dir}/prometheus

cd $(mktemp -d)
wget -q https://github.com/prometheus/prometheus/releases/download/v$${prometheus_version}/prometheus-$${prometheus_version}.linux-amd64.tar.gz

mkdir -p $${install_base_dir}
tar -zxf prometheus-$${prometheus_version}.linux-amd64.tar.gz --strip-components=1 -C $${install_base_dir}
mkdir -p $${data_dir}

# prometheus.yml.tpl is currently found in this repository
# a copy has been uploaded to s3 until I'll figure out the best / most secure way to take it from git
aws s3 cp s3://${prometheus_s3_bucket_name}/prometheus.yml $${install_base_dir}/prometheus.yml

chown -R prometheus.prometheus $${install_base_dir}
chown -R prometheus.prometheus $${data_base_dir}

cat << EOF > /lib/systemd/system/prometheus.service
[Unit]
Description=The Prometheus monitoring system and time series database.
Documentation=https://prometheus.io
After=network.target

[Service]
EnvironmentFile=-/etc/default/prometheus
User=prometheus
WorkingDirectory=$${install_base_dir}
ExecStart=$${install_base_dir}/prometheus --config.file="$${install_base_dir}/prometheus.yml" --web.listen-address="0.0.0.0:9090" --web.external-url="http://${prometheus_domain_name}/" --web.enable-lifecycle --storage.tsdb.path="$${data_base_dir}" \$PROMETHEUS_OPTS
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemd_enable prometheus.service
}


function install_node_exporter(){
add_user_and_group
node_exporter_version='0.16.0'
data_dir=$${data_base_dir}/node_exporter

cd $(mktemp -d)
wget -q https://github.com/prometheus/node_exporter/releases/download/v$${node_exporter_version}/node_exporter-$${node_exporter_version}.linux-amd64.tar.gz
node_exporter_dir=$${install_base_dir}/node_exporter
mkdir -p $${node_exporter_dir}
tar -zxf node_exporter-$${node_exporter_version}.linux-amd64.tar.gz --strip-components=1 -C $${node_exporter_dir}
mkdir -p $${data_dir}
chown -R prometheus.prometheus $${data_dir}

service=node_exporter.service
cat << EOF > /lib/systemd/system/$${service}
[Unit]
Description=Prometheus exporter for machine metrics, written in Go with pluggable metric collectors.
Documentation=https://github.com/prometheus/node_exporter
After=network.target

[Service]
EnvironmentFile=-/etc/default/node_exporter
User=prometheus
WorkingDirectory=$${node_exporter_dir}
ExecStart=$${node_exporter_dir}/node_exporter --collector.textfile.directory=$${data_dir} \$NODE_EXPORTER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemd_enable $${service}
}

function add_user_and_group(){
getent group prometheus >/dev/null || sudo groupadd -r prometheus
getent passwd prometheus >/dev/null || \
useradd -r -g prometheus -d $${install_base_dir} -s /sbin/nologin \
        -c "Prometheus services" prometheus
}

function install_cw_exporter(){
cw_exporter_version="0.1.0"
cw_exporter_port=$${1:-"9106"}
cw_exporter_region=$${2:-"eu-central-1"}

cd /opt/prometheus
wget --tries=2 http://search.maven.org/remotecontent?filepath=io/prometheus/cloudwatch/cloudwatch_exporter/$${cw_exporter_version}/cloudwatch_exporter-$${cw_exporter_version}-jar-with-dependencies.jar -O cloudwatch_exporter-$${cw_exporter_version}-jar-with-dependencies.jar

cat << EOF > /lib/systemd/system/prometheus-cw-exporter-$${cw_exporter_region}.service
[Unit]
Description=Prometheus Cloudwatch Exporter
Documentation=https://prometheus.io
After=network.target

[Service]
User=prometheus
WorkingDirectory=$${install_base_dir}
ExecStart=/usr/bin/java -jar /opt/prometheus/cloudwatch_exporter-$${cw_exporter_version}-jar-with-dependencies.jar $${cw_exporter_port} /opt/prometheus/cw_exporter_config-$${cw_exporter_region}.yml
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

aws s3 cp s3://${prometheus_s3_bucket_name}/cw_exporter_config-$${cw_exporter_region}.yml /opt/prometheus/cw_exporter_config-$${cw_exporter_region}.yml

systemd_enable prometheus-cw-exporter-$${cw_exporter_region}
}


function install_alertmgr(){
alertmgr_ver='${alertmanager_version}'
mkdir -p $${install_base_dir}/alertmanager/{templates,alert_rules}
wget -O - https://github.com/prometheus/alertmanager/releases/download/v$${alertmgr_ver}/alertmanager-$${alertmgr_ver}.linux-amd64.tar.gz | tar xvfz - -C $${install_base_dir}
mv $${install_base_dir}/alertmanager-$${alertmgr_ver}.linux-amd64/* $${install_base_dir}/alertmanager/
aws s3 cp s3://${prometheus_s3_bucket_name}/notifications.tmpl /$${install_base_dir}/templates/
aws s3 cp s3://${prometheus_s3_bucket_name}/alert_rules.yml $${install_base_dir}/alert_rules.yml
aws s3 cp s3://${prometheus_s3_bucket_name}/simple.yml $${install_base_dir}/alertmanager/simple.yml
aws s3 cp s3://${prometheus_s3_bucket_name}/rules.zip $${install_base_dir}/rules.zip
unzip -o $${install_base_dir}/rules.zip -d $${install_base_dir}/alert_rules/ && rm rules.zip
chown -R prometheus.prometheus /$${install_base_dir}/alertmanager
cat << EOF > /lib/systemd/system/alertmanager.service
[Unit]
Description=Prometheus AlertManager
After=network.target

[Service]
User=prometheus
WorkingDirectory=$${install_base_dir}
ExecStart=$${install_base_dir}/alertmanager/alertmanager --web.external-url="http://$${IP}:9093/" --config.file $${install_base_dir}/alertmanager/simple.yml
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemd_enable alertmanager
}

function install_es_exporter() {
sudo adduser --shell /bin/false --no-create-home --disabled-password --disabled-login --gecos ElasticsearchExporter elasticexporter
sudo wget -O /tmp/elasticsearch_exporter.tar.gz "${es_exporter_download_url}"
sudo gunzip /tmp/elasticsearch_exporter.tar.gz
sudo tar -C /tmp -xvf /tmp/elasticsearch_exporter.tar
sudo mkdir /opt/elasticsearch_exporter
sudo mv /tmp/elasticsearch_exporter-*/* /opt/elasticsearch_exporter/
sudo rm -rf /tmp/elasticsearch_exporter*
sudo cat <<EOF > /etc/systemd/system/elasticsearch-exporter.service
[Unit]
Description=elasticsearch exporter service
After=network.target
[Service]
Type=simple
User=elasticexporter
WorkingDirectory=/opt/elasticsearch_exporter
ExecStart=/opt/elasticsearch_exporter/elasticsearch_exporter -es.uri=${es_url} -es.all=true es.indices=true es.shards=true
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

systemd_enable elasticsearch-exporter
}

function systemd_enable(){
systemctl daemon-reload
systemctl enable $1
}

function start_svcs(){
systemctl start prometheus
systemctl start node_exporter
systemctl start prometheus-cw-exporter-eu-central-1
systemctl start prometheus-cw-exporter-us-east-1
systemctl start prometheus-ecs-discovery
systemctl start prometheus-springboot-actuator-ecs-discovery
systemctl start grafana-server
systemctl start alertmanager
if [ "${es_url}" != "" ]; then
  systemctl start elasticsearch-exporter
fi
}

#Main
get_prereqs
set_disks
install_prometheus
install_node_exporter
install_ecs_exporter
install_springboot_discovery
install_cw_exporter
install_cw_exporter 9107 us-east-1
install_alertmgr
install_grafana
if [ "${es_url}" != "" ]; then
  install_es_exporter
fi
start_svcs
