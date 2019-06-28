resource "aws_s3_bucket" "prometheus-bucket" {
  bucket = "${var.prometheus_s3_bucket_name}"
  acl    = "private"
  tags   = "${var.tags}"
}

module "prometheus_cluster" {
  source                      = "./modules/prometheus-cluster"
  node_count                  = "${var.prometheus_node_count}"
  ami                         = "${var.ami_id}"
  instance_type               = "${var.prometheus_instance_type}"
  key_name                    = "${var.key_name}"
  vpc_id                      = "${var.vpc_id}"
  vpc_zone_id                 = ["${var.subnet_id[0]}"]
  subnet_id                   = "${var.subnet_id}"
  user_data                   = ["${data.template_file.prometheus_userdata.*.rendered}"]
  az_name                     = "${var.aws_region}a"
  ebs_device_name             = "${var.device_name}"
  ebs_size                    = "${var.prometheus_ebs_size}"
  ebs_type                    = "${var.prometheus_ebs_type}"
  name                        = "${var.name}-prom"
  tags                        = "${var.tags}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  cidr_blocks                 = "${var.cidr_blocks}"
  alb_target_group_arns       = ["${aws_alb_target_group.prom_tg.arn}", "${aws_alb_target_group.grafana_tg.arn}"]
}

resource "aws_security_group" "prom_grafana_alb_sg" {
  name        = "allow local connections to prom/grafana ALBs on port 443"
  description = "local traffic to 443 for prometheus / grafana"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "prom_grafana_ingress" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.prom_grafana_alb_sg.id}"
}

resource "aws_security_group_rule" "prom_grafana_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.prom_grafana_alb_sg.id}"
}

resource "aws_alb" "prom_alb" {
  name         = "prom-alb"
  internal     = true
  idle_timeout = "300"

  security_groups = [
    "${aws_security_group.prom_grafana_alb_sg.id}",
  ]

  subnets                    = ["${var.subnet_id}"]
  enable_deletion_protection = false

  tags {
    Name = "prom_alb"
  }
}

resource "aws_alb_listener" "prom_alb_listener" {
  load_balancer_arn = "${aws_alb.prom_alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2015-05"
  # certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.prom_tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "prom_tg" {
  name     = "prom-target-group"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path    = "/"
    matcher = "200,302"
  }
}

resource "aws_alb_listener_rule" "prom_listener_rule" {
  listener_arn = "${aws_alb_listener.prom_alb_listener.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.prom_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}
