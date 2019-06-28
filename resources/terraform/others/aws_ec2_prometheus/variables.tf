variable associate_public_ip_address {
  default = "false"
}

variable "prometheus_node_count" {
  default = "1"
}

variable "tags" {
  type = "map"

  default = {
    Owner       = "operations"
    Environment = "dev"
  }
}

variable "ami_id" {
  default = "ami-de486035"
}

variable "prometheus_instance_type" {
  default = "m4.large"
}

variable "prometheus_ebs_type" {
  default = "io1"
}

variable "prometheus_ebs_size" {
  default = "500"
}

variable "device_name" {
  default = "/dev/xvdz"
}

variable "vpc_id" {
  # default = "vpc-4673453d"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "subnet_id" {
  type = "list"
}

variable "key_name" {
  # default = "emr-mvp"
}

variable "prometheus_s3_bucket_name" {
  default = ""
}

variable "grafana_admin_password" {
  default = "duracell@"
}

variable "cidr_blocks" {
  default = ["10.0.0.0/8"]
}

variable "certificate_arn" {
  default = ""
}

variable "slack_webhook_url" {
  default = ""
}

variable "slack_alerts_channel" {
  default = ""
}

variable "name" {}

variable "es_url" {
  default = ""
}

variable "es_exporter_download_url" {
  default = "https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v1.0.3rc1/elasticsearch_exporter-1.0.3rc1.linux-amd64.tar.gz"
}

variable "smtp_smarthost" {
  default = "localhost:25"
}
variable "smtp_from" {
  default = "alertmanager@example.org"
}
variable "smtp_auth_username" {
  default = "alertmanager"
}
variable "smtp_auth_password" {
  default = "passw0rd"
}
variable "alerts_to_email" {
  default = "alerts@example.org"
}

variable "jenkins_domain_name" {
  default = ""
}

variable "prometheus_domain_name" {
  default = ""
}

variable "alertmanager_version" {
  default = "0.14.0"
}

variable "federation_config" {
  type = "list"
  default = []
}
