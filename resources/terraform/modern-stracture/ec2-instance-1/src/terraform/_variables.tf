## module config
variable "deployment_config" {
  description = "deployment configs for tf module"
  type        = "map"
  default     = {
    application-name    = "traiana-con-crushftp",
    aws_account_region  = "",
    aws_profile = "",
  }
}

variable "hosting_vpc_details" {
  description = "vpc details where the application hosts"
  type        = "map"
  default     = {
    vpc_remote_s3bucket   = "",
    vpc_remote_file_path  = "",
  }
}

variable "base_app_tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default     = {
    application-name  = "traiana-con-crushftp",
    businessgroup     = "nex",
    deployment-method = "trf",
    organization      = "traiana",
    owner             = "sre",
    owner-email       = "sre@traiana.com",
    repo-url          = "https://github.com/Traiana/tf-crushftp.git"
  }
}

variable "extra_module_config" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default     = {
    ip_nat_a              = "",
    ip_nat_b              = "",
    ip_nat_c              = "",
    services_cidr_blocks  = "10.126.0.0/20",
    luminate_cidr_blocks  = "",
    ldap_queries_user     = "",
    ldap_uri              = "",
    search_base_location  = "",
    read_only_group_dn    = "",
    sftp_clients_group_dn = "",
    ftp_clients_group_dn  = "",
    sftp_traiana_group_dn = "",
    ftp_traiana_group_dn  = "",
    sftp_abide_group_dn   = "",
    ftp_abide_group_dn    = "",
    sftp_admin_group_dn   = "",
    ftp_admin-group_dn    = "",
    aws_s3_region         = "",
    s3_data_bucket        = "",
  }
}

variable "cluster_nodes_conf" {
  description = "configs for the EFS cluster nodes"
  type        = "map"
  default     = {
    ami_id                            = "",
    associate_public_ip_address       = false,
    cluster_instance_type             = "m4.xlarge",
    ebs_optimized                     = true,
    operational_hours_tag             = "247",
    route53_is_private                = true,
    route53_zone_name                 = "",
    service_cluster_desired_capacity  = 3,
    service_cluster_max_size          = 30,
    service_cluster_min_size          = 3,
    volume_type                       = "gp2",
    volume_size                       = 30,
  }
}

variable "asg_enabeled_metrics" {type="list",default= ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]}

variable "cluster_nodes_userdata_conf" {
  description = "configs for user data"
  type = "map"
  default = {
  }
}

variable "s3_bucket_conf" {
  description = "configs for the S3"
  type        = "map"
  default     = {
    acl                   = "private",
    s3_config_bucket_name = "",
    s3_data_bucket_name   = "",
    versioning_enabled    = true,
  }
}
