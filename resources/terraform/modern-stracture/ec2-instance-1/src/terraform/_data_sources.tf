data "aws_iam_account_alias" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  id = "${data.terraform_remote_state.vpc_bucket_remote_state_file.vpc_id}"
}

data "terraform_remote_state" "vpc_bucket_remote_state_file" {
  backend = "s3"
  config {
    bucket = "${var.hosting_vpc_details["vpc_remote_s3bucket"]}"
    key    = "${var.hosting_vpc_details["vpc_remote_file_path"]}"
    region = "${var.deployment_config["aws_account_region"]}"
    profile = "${var.deployment_config["aws_profile"]}"
  }
}

data "aws_route53_zone" "service_route53_zone" {
  name         = "${var.cluster_nodes_conf["route53_zone_name"]}"
  private_zone = "${var.cluster_nodes_conf["route53_is_private"]}"
}
