resource "aws_security_group" "kibana_sg" {
  name        = "kibana_sg"
  description = "Allow Kibana traffic"
  vpc_id      = "${var.vpc_id}"

  # kibana ports
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# /*
# resource "aws_route53_record" "kibana" {
#   name    = "kibana"
#   zone_id = "${var.zone_id}"
#   type    = "A"
#   ttl     = 300
#   records = ["${aws_instance.kibana.private_ip}"]
# }
# */

resource "aws_security_group" "kibana_alb_sg" {
  name   = "${var.name}-alb-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = "${var.kibana_alb_port}"
    to_port     = "${var.kibana_alb_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "kibana_alb" {
  name            = "${var.name}-alb"
  internal        = "true"
  security_groups = ["${aws_security_group.kibana_alb_sg.id}"]
  subnets         = ["${var.alb_subnet_id}"]
  idle_timeout    = "120"

  enable_deletion_protection = false
  tags                       = "${merge(var.tags, map("Name", "kibana-alb"))}"
}

resource "aws_autoscaling_attachment" "kibana_asg_attachment" {
  alb_target_group_arn   = "${aws_alb_target_group.kibana_target_group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.kibana.id}"
}

resource "aws_alb_target_group" "kibana_target_group" {
  count    = "${var.target_count}"
  name     = "${var.name}-tg"
  port     = "5601"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path     = "/login"
    protocol = "HTTP"
    port     = "5601"
  }
}

resource "aws_alb_listener" "kibana_listener" {
  load_balancer_arn = "${aws_alb.kibana_alb.arn}"
  port              = "${var.kibana_alb_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.kibana_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_launch_configuration" "launch_config" {
  name_prefix     = "${var.name}-lc"
  image_id        = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.kibana_sg.id}"]
  user_data       = "${var.user_data}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kibana" {
  name                 = "${var.name}-asg"
  availability_zones   = ["${var.az_name}"]
  launch_configuration = "${aws_launch_configuration.launch_config.name}"
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = ["${var.subnet_id}"]
  target_group_arns    = ["${aws_alb_target_group.kibana_target_group.arn}"]

  lifecycle {
    create_before_destroy = true
  }

  tag = {
    key                 = "Name"
    value               = "${var.name}${count.index + 1}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Owner"
    value               = "${lookup(var.tags, "owner")}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "environment"
    value               = "${lookup(var.tags, "environment")}"
    propagate_at_launch = true
  }
}
