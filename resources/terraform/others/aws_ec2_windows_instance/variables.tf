variable "name" {
  type        = "string"
  description = "Name of the Windows JumpHost Server"
}

variable "tags" {
  type        = "map"
  description = "Map of tags to apply to supported resources"
}

variable "subnet_id" {
  type        = "string"
  description = "subnet_id to deploy the Windows JumpHost server into"
}

variable "key_name" {
  type        = "string"
  description = "Name of the SSH key to deploy to the Windows JumpHost server"
}

variable "instance_size" {
  type        = "string"
  description = "Instance Size"
  default     = "t2.large"
}

variable "vpc_security_group_ids" {
  type        = "list"
  description = "List of security groups to apply to the JumpHost"
}

variable "monitoring" {
  type        = "string"
  description = "Boolean enabling advanced cloudwatch metrics"
  default     = "false"
}

variable "ami_name_filter" {
  type        = "string"
  description = "define a filter for selecting an AMI"
  default     = "Windows_Server-2016-English-Full-Base-*"
}

variable "root_volume_size" {
  type        = "string"
  description = "The size of the volume in gigabytes."
  default     = 30
}

variable "root_volume_type" {
  type        = "string"
  description = "The type of volume. Can be standard, gp2, or io1. (Default: standard)."
  default     = "standard"
}

variable "root_delete_on_termination" {
  type        = "string"
  description = "Whether the volume should be destroyed on instance termination (Default: true)."
  default     = true
}
