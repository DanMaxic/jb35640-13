# module: es_cluster

# /*resource "aws_route53_record" "es_alb" {
#   name    = "${var.name}"
#   zone_id = "${var.vpc_zone_id}"
#   type    = "A"
#
#   alias {
#     name                   = "${aws_alb.es_alb.dns_name}"
#     zone_id                = "${aws_alb.es_alb.zone_id}"
#     evaluate_target_health = true
#   }
# }
# */

resource "aws_alb" "es_alb" {
  name            = "${var.name}-alb"
  internal        = "true"
  security_groups = ["${aws_security_group.es_alb_sg.id}"]
  subnets         = ["${var.alb_subnet_id}"]
  idle_timeout    = "3601"

  enable_deletion_protection = false
  tags                       = "${merge(var.tags, map("Name", "${var.name}-alb"))}"
}

resource "aws_alb_target_group" "es_target_group" {
  count    = "${var.target_count}"
  name     = "${var.name}${element(var.target_ports,count.index)}-tg"
  port     = "${element(var.target_ports,count.index)}"
  protocol = "${element(var.target_protocols,count.index)}"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path     = "${element(var.target_check_paths,count.index)}"
    protocol = "${element(var.target_check_protocols,count.index)}"
    port     = "${element(var.target_check_ports,count.index)}"
  }
}

resource "aws_alb_listener" "es_listener" {
  count             = "${var.target_count}"
  load_balancer_arn = "${aws_alb.es_alb.arn}"
  port              = "${element(var.target_ports,count.index)}"
  protocol          = "${element(var.target_protocols,count.index)}"

  default_action {
    target_group_arn = "${element(aws_alb_target_group.es_target_group.*.arn,count.index)}"
    type             = "forward"
  }
}

resource "aws_security_group" "es_alb_sg" {
  name   = "${var.name}-alb-sg"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "es_alb_sg_ports" {
  count             = "${var.target_count}"
  type              = "ingress"
  from_port         = "${element(var.target_ports,count.index)}"
  to_port           = "${element(var.target_ports,count.index)}"
  protocol          = "TCP"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.es_alb_sg.id}"
}

resource "aws_launch_configuration" "launch_config" {
  name_prefix                 = "${var.name}${count.index + 1}-lc-"
  count                       = "${var.node_count}"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${concat(var.vpc_security_group_ids,list(aws_security_group.allow_es_inbound.id))}"]
  user_data                   = "${element(var.user_data,count.index)}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "elastic" {
  name                 = "${var.name}${count.index + 1}-asg"
  count                = "${var.node_count}"
  availability_zones   = ["${var.az_name}"]
  launch_configuration = "${element(aws_launch_configuration.launch_config.*.name, count.index)}"
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = ["${var.subnet_id[0]}"]
  target_group_arns    = ["${aws_alb_target_group.es_target_group.*.arn}"]

  lifecycle {
    create_before_destroy = true
  }

  tag = {
    key                 = "environment"
    value               = "${lookup(var.tags, "environment")}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "${var.name}${count.index + 1}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "cluster"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "ebs_volume_ids"
    value               = "${element(aws_ebs_volume.elastic_ebs.*.id, count.index)}"
    propagate_at_launch = true
  }

  depends_on = ["aws_ebs_volume.elastic_ebs"]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    sid     = ""
    actions = ["sts:AssumeRole"]

    principals = [
      {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      },
    ]
  }
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    effect = "Allow"
    sid    = ""

    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.name}_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "assume_role" {
  name   = "${var.name}_iam_role_policy"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${data.aws_iam_policy_document.policy_document.json}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}_instance_profile"
  role = "${aws_iam_role.instance_role.name}"
}

resource "aws_ebs_volume" "elastic_ebs" {
  count             = "${var.node_count}"
  availability_zone = "${var.az_name}"
  size              = "${var.ebs_size}"
  type              = "${var.ebs_type}"
  tags              = "${merge(var.tags, map("Name", "${var.name}${count.index + 1}_ebs"))}"
}

# es related SG's
resource "aws_security_group" "allow_es_inbound" {
  name        = "allow_es_inbound_${var.name}"
  description = "Allow all inbound traffic to standard es and ssh ports"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_ingress_es" {
  type                     = "ingress"
  count                    = "${var.source_security_group_count * var.es_port_count}"
  from_port                = "${element(var.es_port, count.index)}"
  to_port                  = "${element(var.es_port, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.vpc_security_group_ids, count.index)}"
  security_group_id        = "${aws_security_group.allow_es_inbound.id}"
}

resource "aws_security_group_rule" "allow_ingress_cidr_es" {
  type              = "ingress"
  count             = "${var.es_port_count}"
  from_port         = "${element(var.es_port, count.index)}"
  to_port           = "${element(var.es_port, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.allow_es_inbound.id}"
}

resource "aws_security_group_rule" "allow_egress_es" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.allow_es_inbound.id}"
}
