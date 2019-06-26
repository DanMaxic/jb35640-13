locals {
  crushftp_elb_tags = {
    application-role  = "security-group"
    name              = "crushftp-elb"
    Name              = "crushftp-elb"
    location          = "${data.aws_region.current.name}"
    environment       = "${data.aws_iam_account_alias.current.account_alias}"
  }
}

/* sftp only*/
resource "aws_elb" "crushftp_elb" {
  name            = "crushftp-elb"
  internal        = "true"
  security_groups = ["${aws_security_group.crushftp_elb_sg.id}"]
  subnets         = ["${data.terraform_remote_state.vpc_bucket_remote_state_file.public_subnets_ids}"]
  tags            = "${merge(var.base_app_tags,local.crushftp_elb_tags)}"

  listener {
    instance_port     = "2222"
    instance_protocol = "tcp"
    lb_port           = "22"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:2222"
    interval            = "20"
  }
}

resource "aws_route53_record" "service_elb_route53_record" {
  zone_id = "${data.aws_route53_zone.service_route53_zone.zone_id}"
  name    = "${format("%s-%s",var.deployment_config["application-name"], local.aws_account_name)}"
  type    = "A"
  alias {
    name                   = "${aws_elb.crushftp_elb.dns_name}"
    zone_id                = "${aws_elb.crushftp_elb.zone_id}"
    evaluate_target_health = true
  }
}

/* ftp only */
resource "aws_elb" "crushftp_ftp_elb" {
  name = "crushftp-ftp-elb"
  internal = "true"
  security_groups = ["${aws_security_group.crushftp_elb_sg.id}"]
  subnets = ["${data.terraform_remote_state.vpc_bucket_remote_state_file.public_subnets_ids}"]
  tags = "${merge(var.base_app_tags,local.crushftp_elb_tags)}"
  listener {
    instance_port     = "2121"
    instance_protocol = "tcp"
    lb_port           = "21"
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:21"
    interval            = "20"
  }
}

resource "aws_route53_record" "service_ftp_elb_route53_record" {
  zone_id = "${data.aws_route53_zone.service_route53_zone.zone_id}"
  name    = "${format("%s-ftp-%s",var.deployment_config["application-name"], local.aws_account_name)}"
  type    = "A"
  alias {
    name                   = "${aws_elb.crushftp_ftp_elb.dns_name}"
    zone_id                = "${aws_elb.crushftp_elb.zone_id}"
    evaluate_target_health = true
  }
}
