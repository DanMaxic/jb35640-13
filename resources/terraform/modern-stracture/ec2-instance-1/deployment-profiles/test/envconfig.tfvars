deployment_config = {
  aws_profile = "my_prof"
  aws_account_region  = "us-east-1"
}

hosting_vpc_details = {
  vpc_remote_s3bucket   = "tf-state-bucket",
  vpc_remote_file_path  = ".tfstate"
}

cluster_nodes_conf = {
  #ami_id              = "ami-01745c536588ca107",
  ami_id              = "ami-0f4a3324f8efd1ca6",
  route53_zone_name   = "bilbi.pro.",
  route53_is_private  = false
}

extra_module_config = {
  ip_nat_a              = "auto",
  ip_nat_b              = "auto",
  ip_nat_c              = "auto",

}

s3_bucket_conf =  {
  s3_config_bucket_name = "config",
  s3_data_bucket_name   = "data",
}
