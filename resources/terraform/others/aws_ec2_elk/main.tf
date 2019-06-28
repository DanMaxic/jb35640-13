data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "es_userdata" {
  template = "${file("${path.module}/es-userdata.sh.tpl")}"
  count    = "${var.es_node_count}"

  vars {
    device               = "${var.device_name}"
    region               = "${var.region}"
    cluster_name         = "${var.name}"
    number_of_replicas   = "${var.es_node_count}"
    minimum_master_nodes = "${var.es_node_count}"
    ek_version           = "${var.ek_version}"
  }
}

data "template_file" "kibana_userdata" {
  template = "${file("${path.module}/kibana-userdata.sh.tpl")}"

  vars {
    es_url     = "http://${module.es_cluster.dns_name}:9200"
    ek_version = "${var.ek_version}"
  }
}

module "es_cluster" {
  source        = "./es_cluster"
  node_count    = "${var.es_node_count}"
  ami           = "${data.aws_ami.ubuntu.image_id}"
  instance_type = "${var.es_instance_type}"
  key_name      = "${var.key_name}"
  vpc_id        = "${var.vpc_id}"

  #vpc_zone_id   = "${data.terraform_remote_state.vpc.route53_zone_id}"
  subnet_id     = ["${var.subnet_id}"]
  user_data     = ["${data.template_file.es_userdata.*.rendered}"]
  name          = "${var.name}"
  az_name       = "${var.region}a"
  tags          = "${var.tags}"
  alb_subnet_id = "${var.alb_subnet_id}"

  # alb_subnet_id   = ["${var.subnet_id}"]
}

module "kibana" {
  source          = "./kibana"
  node_count      = "${var.kibana_node_count}"
  ami_id          = "${data.aws_ami.ubuntu.image_id}"
  instance_type   = "${var.kibana_instance_type}"
  key_name        = "${var.key_name}"
  user_data       = "${data.template_file.kibana_userdata.rendered}"
  name            = "kibana"
  subnet_id       = "${var.subnet_id[0]}"
  vpc_id          = "${var.vpc_id}"
  az_name         = "${var.region}a"
  tags            = "${var.tags}"
  alb_subnet_id   = "${var.alb_subnet_id}"
  kibana_alb_port = "${var.kibana_alb_port}"
}
