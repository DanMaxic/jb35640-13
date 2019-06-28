# module: prometheus_cluster

resource "aws_launch_configuration" "launch_config" {
  name_prefix     = "${var.name}${count.index + 1}-lc-"
  count           = "${var.node_count}"
  image_id        = "${var.ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${concat(var.vpc_security_group_ids,list(aws_security_group.allow_prometheus_inbound.id))}"]
  user_data       = "${element(var.user_data,count.index)}"

  associate_public_ip_address = "${var.associate_public_ip_address}"

  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "prometheus" {
  name                 = "${var.name}${count.index + 1}-asg"
  count                = "${var.node_count}"
  launch_configuration = "${element(aws_launch_configuration.launch_config.*.name, count.index)}"
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = ["${var.vpc_zone_id}"]
  # availability_zones   = ["${var.az_name}"]

  target_group_arns = ["${var.alb_target_group_arns}"]

  lifecycle {
    create_before_destroy = true
  }

  tag = {
    key                 = "Name"
    value               = "${var.name}${count.index + 1}"
    propagate_at_launch = true
  }

  # tag = {
  #   key                 = "Owner"
  #   value               = "${lookup(var.tags, "Owner")}"
  #   propagate_at_launch = true
  # }

  # tag = {
  #   key                 = "Environment"
  #   value               = "${lookup(var.tags, "Environment")}"
  #   propagate_at_launch = true
  # }

  tag = {
    key                 = "ebs_volume_ids"
    value               = "${element(aws_ebs_volume.prometheus_ebs.*.id, count.index)}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Backup"
    value               = "True"
    propagate_at_launch = true
  }

  depends_on = ["aws_ebs_volume.prometheus_ebs"]
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

    # TBD: harden IAM
    actions = [
      "ec2:*",
      "s3:*",
      "ecs:*",
      "cloudwatch:*",
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

resource "aws_ebs_volume" "prometheus_ebs" {
  count             = "${var.node_count}"
  availability_zone = "${var.az_name}"
  size              = "${var.ebs_size}"
  type              = "${var.ebs_type}"
  iops              = "${var.ebs_iops_number}"
  tags              = "${merge(var.tags, map("Name", "${var.name}${count.index + 1}_ebs"))}"
}

resource "aws_security_group" "allow_prometheus_inbound" {
  name        = "allow_prometheus_inbound_${var.name}"
  description = "Allow all inbound traffic to standard prometheus and ssh ports"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_ingress_prometheus" {
  type                     = "ingress"
  count                    = "${var.source_security_group_count * var.prometheus_port_count}"
  from_port                = "${element(var.prometheus_port, count.index)}"
  to_port                  = "${element(var.prometheus_port, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.vpc_security_group_ids, count.index)}"
  security_group_id        = "${aws_security_group.allow_prometheus_inbound.id}"
}

resource "aws_security_group_rule" "allow_ingress_cidr_prometheus" {
  type              = "ingress"
  count             = "${var.prometheus_port_count}"
  from_port         = "${element(var.prometheus_port, count.index)}"
  to_port           = "${element(var.prometheus_port, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.allow_prometheus_inbound.id}"
}

resource "aws_security_group_rule" "allow_egress_prometheus" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.allow_prometheus_inbound.id}"
}
