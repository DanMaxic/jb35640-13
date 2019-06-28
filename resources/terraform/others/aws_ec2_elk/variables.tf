variable "es_node_count" {
  default = "3"
}

variable "kibana_node_count" {
  default = "1"
}

variable "kibana_alb_port" {
  default = 80
}

variable "name" {}

variable "es_instance_type" {
  default = "m3.medium"
}

variable "kibana_instance_type" {
  default = "t2.medium"
}

variable "tags" {
  type = "map"
}

variable "device_name" {
  type    = "string"
  default = "/dev/xvdz"
}

variable "vpc_id" {}

variable "subnet_id" {
  type = "list"
}

variable "key_name" {
  default = "ssh_key"
}

variable "region" {
  default = "eu-central-1"
}

variable "vpc_zone_id" {
  default = ""
}

variable "alb_subnet_id" {
  type    = "list"
  default = []
}

variable "ek_version" {
  default = "6.3.0"
}
