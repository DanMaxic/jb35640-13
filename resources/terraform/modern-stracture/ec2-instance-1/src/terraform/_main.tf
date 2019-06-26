provider "aws" {
  version = "1.13"
  profile = "${var.deployment_config["aws_profile"]}"
  region = "${var.deployment_config["aws_account_region"]}"
}
provider "template" { version = "1.0" }
provider "null" { version = "1.0" }

terraform {
  backend "s3" {
  }
}
