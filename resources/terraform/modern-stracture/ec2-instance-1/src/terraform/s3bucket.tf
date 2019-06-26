locals {
  s3_config_bucket  = {
    application-role  = "config storage for service"
    name              = "${var.s3_bucket_conf["s3_config_bucket_name"]}"
    Name              = "${var.s3_bucket_conf["s3_config_bucket_name"]}"
    location          = "${data.aws_region.current.name}"
    environment       = "${data.aws_iam_account_alias.current.account_alias}"
  }
  s3_data_bucket  = {
    application-role  = "config storage for service"
    name              = "${var.s3_bucket_conf["s3_data_bucket_name"]}"
    Name              = "${var.s3_bucket_conf["s3_data_bucket_name"]}"
    location          = "${data.aws_region.current.name}"
    environment       = "${data.aws_iam_account_alias.current.account_alias}"
  }
}

resource "aws_s3_bucket" "s3_config_bucket" {
  # bucket  = "${data.aws_iam_account_alias.current.account_alias}-crushftp-config"
  bucket  = "${var.s3_bucket_conf["s3_config_bucket_name"]}"
  acl     = "${var.s3_bucket_conf["acl"]}"
  tags    = "${merge(var.base_app_tags,local.s3_config_bucket)}"
  versioning {enabled = "${var.s3_bucket_conf["versioning_enabled"]}"}
}

resource "aws_s3_bucket" "s3_data_bucket" {
  # bucket  = "${data.aws_iam_account_alias.current.account_alias}-crushftp-data"
  bucket  = "${var.s3_bucket_conf["s3_data_bucket_name"]}"
  acl     = "${var.s3_bucket_conf["acl"]}"
  tags    = "${merge(var.base_app_tags,local.s3_data_bucket)}"
  versioning {enabled = "${var.s3_bucket_conf["versioning_enabled"]}"}
}

// new test resource
resource "null_resource" "example" {}
