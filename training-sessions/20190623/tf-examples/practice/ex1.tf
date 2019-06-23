

##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
default = "defaultKeys"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
access_key = "${var.aws_access_key}"
secret_key = "${var.aws_secret_key}"
region     = "us-east-1"
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "nginx" {
ami           = "ami-c58c1dd3"
instance_type = "t2.micro"
key_name        = "${var.key_name}"
user_data = "sudo yum install nginx -y && sudo service nginx start"
}



##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
value = "${aws_instance.nginx.public_dns}"
}

