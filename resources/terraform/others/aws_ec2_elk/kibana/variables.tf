variable "ami_id" {}

variable "instance_type" {}

variable "key_name" {
  default = "deployer-key"
}

variable "user_data" {}

variable "associate_public_ip_address" {
  default = "false"
}

variable "subnet_id" {}

variable "vpc_id" {}

#variable "zone_id" {}

variable "tags" {
  type = "map"
}

variable "node_count" {}

variable "target_count" {
  type    = "string"
  default = 1
}

variable "az_name" {}

variable "alb_subnet_id" {
  type = "list"
}

variable "name" {}

variable "kibana_alb_port" {
  default = "80"
}
