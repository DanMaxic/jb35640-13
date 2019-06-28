#!/bin/bash -x

es_root='/opt/elasticsearch'

NODE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
if [ -z "$NODE_NAME" ]; then
  NODE_NAME=$(hostname)
fi

function set_disks() {
sudo apt-get update
sudo apt-get install python-pip -y
sudo pip install awscli
dev="${device}"

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
    mkdir -p $${es_root}/{log,data}

    if ! file -sL $${dev} | grep ext4 ; then
      mkfs.ext4 $${dev} -L $(hostname)
    fi
    if ! grep -q "$${dev} $${es_root}" "/etc/fstab" ; then
      sed -i '/\/mnt/d' /etc/fstab
      echo "$${dev} $${es_root} ext4 noatime,nodiratime,data=writeback,nobh,delalloc 0 0" >> /etc/fstab
    fi
    mount -a
fi
}

function install_es(){

curl -s https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo add-apt-repository ppa:webupd8team/java
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get update
sudo apt-get install -y oracle-java8-installer oracle-java8-set-default elasticsearch=${ek_version}
sudo chown -R elasticsearch:elasticsearch $${es_root}

# get aws ec2 es-plugin
yes|/usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2
REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
cat <<EOF | sudo tee /etc/elasticsearch/elasticsearch.yml
node.name: $NODE_NAME
cluster.name: ${cluster_name}
network.host: _ec2_
path:
  logs: $${es_root}/log
  data: $${es_root}/data
discovery.ec2.tag.cluster: ${cluster_name}
discovery.zen.hosts_provider: ec2
discovery.ec2.endpoint: ec2.$${REGION}.amazonaws.com
discovery.zen.minimum_master_nodes: 2
cloud.node.auto_attributes: true
cluster.routing.allocation.awareness.attributes: aws_availability_zone
EOF

# Must be changed when bootstrap.mlockall: true + several tunings
cat <<END > /etc/default/elasticsearch
ES_HEAP_SIZE=$(free -g | grep Mem | awk '{printf "%.0fg", $2 * .5}')
MAX_LOCKED_MEMORY=unlimited
MAX_OPEN_FILES=65536
END
ES_HEAP_SIZE=$(free -g | grep Mem | awk '{printf "%.0f", $2 * .5}')
sed -i "s/-Xm\([x|s]\)[0-9]*g/-Xm\1$${ES_HEAP_SIZE}g/g" /etc/elasticsearch/jvm.options


sudo systemctl daemon-reload
sudo service elasticsearch restart
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

#main
set_disks
install_es
install_nodeexporter
