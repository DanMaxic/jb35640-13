locals {
  elb_security_group = {
    application-role  = "security-group"
    name              = "${var.deployment_config["application-name"]}_nodes_sg"
    Name              = "${var.deployment_config["application-name"]}_nodes_sg"
    location          = "${data.aws_region.current.name}"
    environment       = "${data.aws_iam_account_alias.current.account_alias}"
  }
}

resource "aws_security_group" "crushftp_elb_sg" {
  name        = "crushftp-elb-sg"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "security group for crushftp elb"
  tags        = "${merge(var.base_app_tags,local.elb_security_group)}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow sftp"
  }

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ftp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all out"
  }
}