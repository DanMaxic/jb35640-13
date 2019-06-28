variable "ami" {}

variable "node_count" {}

variable "associate_public_ip_address" {
  default = "false"
}

variable "instance_type" {}

variable "key_name" {}

variable "subnet_id" {
  type = "list"
}

variable "alb_subnet_id" {
  type = "list"
}

variable "vpc_security_group_ids" {
  type    = "list"
  default = []
}

/*variable "vpc_zone_id" {
  type = "string"
}
*/

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
  default = "elastic"
}

variable "ebs_size" {
  type    = "string"
  default = "300"
}

variable "ebs_device_name" {
  type    = "string"
  default = "/dev/xvdz"
}

variable "ebs_type" {
  type    = "string"
  default = "gp2"
}

variable "source_security_group_count" {
  description = "Count of security groups"
  default     = "0"
}

variable "es_port_count" {
  default = "4"
}

variable "es_port" {
  type    = "list"
  default = ["22", "9100", "9200", "9300"]
}

variable "cidr_blocks" {
  type    = "list"
  default = ["10.0.0.0/8"]
}

variable "target_count" {
  type    = "string"
  default = 1
}

variable "target_ports" {
  type    = "list"
  default = ["9200"]
}

variable "target_protocols" {
  type    = "list"
  default = ["HTTP"]
}

variable "target_check_protocols" {
  type    = "list"
  default = ["HTTP"]
}

variable "target_check_paths" {
  type    = "list"
  default = ["/_cluster/health"]
}

variable "target_check_ports" {
  type    = "list"
  default = ["9200"]
}

variable "vpc_id" {}
