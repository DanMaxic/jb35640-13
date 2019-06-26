locals {
  crushftp_nlb_tags = {
    application-role = "security-group"
    name             = "crushftp-elb"
    Name             = "crushftp-elb"
    location         = "${data.aws_region.current.name}"
    environment      = "${data.aws_iam_account_alias.current.account_alias}"
  },
  vpc_id  = "${data.terraform_remote_state.vpc_bucket_remote_state_file.vpc_id}"
}

/* sftp only */
resource "aws_lb" "crushftp_nlb" {
  name                              = "crushftp-nlb"
  internal                          = true
  load_balancer_type                = "network"
  enable_cross_zone_load_balancing  = false
  subnets                           = ["${data.terraform_remote_state.vpc_bucket_remote_state_file.public_subnets_ids}"]
  tags                              = "${merge(var.base_app_tags,local.crushftp_nlb_tags)}"
}

resource "aws_lb_target_group" "crushftp_sftp_target_group" {
  name     = "crushftp-sftp-target-group"
  port     = 2222
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"
  tags     = "${merge(var.base_app_tags)}"
}

resource "aws_lb_listener" "crushftp_nlb_sftp_listener" {
  load_balancer_arn = "${aws_lb.crushftp_nlb.arn}"
  port              = "22"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.crushftp_sftp_target_group.arn}"
    type             = "forward"
  }
}

/*ftp only*/
resource "aws_lb" "crushftp_ftp_nlb" {
  name                              = "crushftp-ftp-nlb"
  internal                          = true
  load_balancer_type                = "network"
  enable_cross_zone_load_balancing  = false
  subnets                           = ["${data.terraform_remote_state.vpc_bucket_remote_state_file.public_subnets_ids}"]
  tags                              = "${merge(var.base_app_tags,local.crushftp_nlb_tags)}"
}

# ftp 21
resource "aws_lb_target_group" "crushftp_ftp_target_group" {
  name     = "crushftp-ftp-target-group"
  port     = 21
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"
  tags     = "${merge(var.base_app_tags)}"
}

resource "aws_lb_listener" "crushftp_nlb_ftp_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "21"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.crushftp_ftp_target_group.arn}"
    type             = "forward"
  }
}

# ftp 60k
resource "aws_lb_target_group" "crushftp_ftp_60k_target_group" {
  name      = "crushftp-ftp-60k-target-group"
  port      = 60000
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60000"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k_target_group.arn}"
    type              = "forward"
  }
}

# ftp 60k1
resource "aws_lb_target_group" "crushftp_ftp_60k1_target_group" {
  name      = "crushftp-ftp-60k1-target-group"
  port      = 60001
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k1_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60001"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.crushftp_ftp_60k1_target_group.arn}"
    type             = "forward"
  }
}

# ftp 60k2
resource "aws_lb_target_group" "crushftp_ftp_60k2_target_group" {
  name      = "crushftp-ftp-60k2-target-group"
  port      = 60002
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k2_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60002"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k2_target_group.arn}"
    type              = "forward"
  }
}

# ftp 60k3
resource "aws_lb_target_group" "crushftp_ftp_60k3_target_group" {
  name      = "crushftp-ftp-60k3-target-group"
  port      = 60003
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k3_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60003"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k3_target_group.arn}"
    type              = "forward"
  }
}

#ftp 60k4
resource "aws_lb_target_group" "crushftp_ftp_60k4_target_group" {
  name      = "crushftp-ftp-60k4-target-group"
  port      = 60004
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k4_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60004"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k4_target_group.arn}"
    type              = "forward"
  }
}

#ftp 60k5
resource "aws_lb_target_group" "crushftp_ftp_60k5_target_group" {
  name      = "crushftp-ftp-60k5-target-group"
  port      = 60005
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k5_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60005"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k5_target_group.arn}"
    type              = "forward"
  }
}

#ftp 60k6
resource "aws_lb_target_group" "crushftp_ftp_60k6_target_group" {
  name      = "crushftp-ftp-60k6-target-group"
  port      = 60006
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k6_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60006"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k6_target_group.arn}"
    type              = "forward"
  }
}

#ftp 60k7
resource "aws_lb_target_group" "crushftp_ftp_60k7_target_group" {
  name      = "crushftp-ftp-60k7-target-group"
  port      = 60007
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k7_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60007"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k7_target_group.arn}"
    type              = "forward"
  }
}

#ftp 60k8
resource "aws_lb_target_group" "crushftp_ftp_60k8_target_group" {
  name      = "crushftp-ftp-60k8-target-group"
  port      = 60008
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k8_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60008"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k8_target_group.arn}"
    type              = "forward"
  }
}

#ftp 60k9
resource "aws_lb_target_group" "crushftp_ftp_60k9_target_group" {
  name      = "crushftp-ftp-60k9-target-group"
  port      = 60009
  protocol  = "TCP"
  vpc_id    = "${local.vpc_id}"
  tags      = "${merge(var.base_app_tags)}"
  health_check {
    protocol  = "TCP"
    port      = "21"
  }
}

resource "aws_lb_listener" "crushftp_nlb_60k9_listener" {
  load_balancer_arn = "${aws_lb.crushftp_ftp_nlb.arn}"
  port              = "60009"
  protocol          = "TCP"
  default_action {
    target_group_arn  = "${aws_lb_target_group.crushftp_ftp_60k9_target_group.arn}"
    type              = "forward"
  }
}