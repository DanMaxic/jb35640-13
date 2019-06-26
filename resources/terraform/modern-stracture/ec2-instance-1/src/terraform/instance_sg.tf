locals {
  cluster_instances_security_group = {
    application-role = "security-group"
    name = "crushftp-instance-sg"
    Name = "crushftp-instance-sg"
    location = "${data.aws_region.current.name}"
    environment = "${data.aws_iam_account_alias.current.account_alias}"
  }
}
resource "aws_security_group" "crushftp_instance_sg" {
  name        = "crushftp-instance-sg"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "security group for crushftp instances"
  tags = "${merge(var.base_app_tags,local.elb_security_group)}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.extra_module_config["services_cidr_blocks"]}","${var.extra_module_config["luminate_cidr_blocks"]}"]
    description = "allow instance ssh"
  }

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ftp"
  }

  ingress {
    from_port   = 2121
    to_port     = 2121
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ftp"
  }

  ingress {
    from_port   = 60000
    to_port     = 60009
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ftp high ports"
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow sftp"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.extra_module_config["services_cidr_blocks"]}","${var.extra_module_config["luminate_cidr_blocks"]}"]
    description = ""
  }

    ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${var.extra_module_config["services_cidr_blocks"]}"]
    description = ""
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.extra_module_config["services_cidr_blocks"]}"]
    description = ""
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all out"
  }
}