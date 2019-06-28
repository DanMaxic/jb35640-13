data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name_filter}*"]
  }

  owners = ["amazon"]

  name_regex = "^${var.ami_name_filter}.*-x86_64-gp2"
}


data "template_file" "es_userdata" {
  template = "${file("${path.module}/es-userdata.sh.tpl")}"

  vars {

  }
}

resource "aws_instance" "main" {
  count                  = 1
  ami                    = "${data.aws_ami.ami.image_id}"
  instance_type          = "${var.instance_size}"
  key_name               = "${var.key_name}"
  monitoring             = "${var.monitoring}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  subnet_id              = "${var.subnet_id}"
  iam_instance_profile   = "${aws_iam_instance_profile.instance_profile.name}"

  root_block_device = {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_delete_on_termination}"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }
  user_data = ""
  tags = "${merge(var.tags, map("Name","${var.name}",))}"
}
