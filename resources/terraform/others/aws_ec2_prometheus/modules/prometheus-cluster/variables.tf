variable "ami" {}

variable "node_count" {}

variable "associate_public_ip_address" {
  default = "true"
}

variable "instance_type" {}

variable "key_name" {}

variable "subnet_id" {
  type = "list"
}

variable "vpc_security_group_ids" {
  type    = "list"
  default = []
}

variable "vpc_zone_id" {
  type = "list"
}

variable "user_data" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "az_name" {
  type = "string"
}

variable "name" {
  type    = "string"
  default = "prometheus"
}

variable "ebs_size" {
  type    = "string"
  default = "500"
}

variable "ebs_iops_number" {
  type    = "string"
  default = "500"
}

variable "ebs_device_name" {
  type    = "string"
  default = "/dev/xvdz"
}

variable "ebs_type" {
  type    = "string"
  default = "io1"
}

variable "source_security_group_count" {
  description = "Count of security groups"
  default     = "0"
}

variable "prometheus_port_count" {
  default = "9"
}

variable "prometheus_port" {
  type    = "list"
  default = ["22", "9090", "3000", "80", "9093", "9106", "9107", "9100", "9108"]
}

variable "cidr_blocks" {
  type        = "list"
  default     = ["10.0.0.0/8"]
  description = "Allow access from this range"
}

variable "vpc_id" {}

variable "alb_target_group_arns" {
  type    = "list"
  default = []
}
