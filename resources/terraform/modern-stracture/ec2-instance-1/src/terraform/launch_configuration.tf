data "template_file" "user_data" {
  template  = "${file("${path.module}/templates/user_data.sh")}"
  vars {
    IP_NAT_A        = "${var.extra_module_config["ip_nat_a"]}"
    IP_NAT_B        = "${var.extra_module_config["ip_nat_b"]}"
    IP_NAT_C        = "${var.extra_module_config["ip_nat_c"]}"
    s3_config_files = "${aws_s3_bucket.s3_config_bucket.bucket}"
    QUERIES_USER    = "${var.extra_module_config["ldap_queries_user"]}"
    LDAP_URI        = "${var.extra_module_config["ldap_uri"]}"
    SBL             = "${var.extra_module_config["search_base_location"]}"
    RO_DN           = "${var.extra_module_config["read_only_group_dn"]}"
    SFTP_C_DN       = "${var.extra_module_config["sftp_clients_group_dn"]}"
    FTP_C_DN        = "${var.extra_module_config["ftp_clients_group_dn"]}"
    SFTP_T_DN       = "${var.extra_module_config["sftp_traiana_group_dn"]}"
    FTP_T_DN        = "${var.extra_module_config["ftp_traiana_group_dn"]}"
    SFTP_AB_DN      = "${var.extra_module_config["sftp_abide_group_dn"]}"
    FTP_AB_DN       = "${var.extra_module_config["ftp_abide_group_dn"]}"
    SFTP_AD_DN      = "${var.extra_module_config["sftp_admin_group_dn"]}"
    FTP_AD_DN       = "${var.extra_module_config["ftp_admin-group_dn"]}"
    S3_REGION       = "${var.extra_module_config["aws_s3_region"]}"
    S3_DATA_BUCKET  = "${var.extra_module_config["s3_data_bucket"]}"
  }
}

resource "aws_launch_configuration" "crushftp_lc" {
  name_prefix                 = "${var.deployment_config["application-name"]}_node"
  image_id                    = "${lookup(var.cluster_nodes_conf,"ami_id")}"
  instance_type               = "${lookup(var.cluster_nodes_conf,"cluster_instance_type")}"
  security_groups             = ["${aws_security_group.crushftp_instance_sg.id}"]
  user_data                   = "${data.template_file.user_data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.crushftp_instance_profile.name}"
  key_name                    = "${aws_key_pair.luminate_public_key.key_name}"
  associate_public_ip_address = "${lookup(var.cluster_nodes_conf,"associate_public_ip_address")}"
  ebs_optimized               = "${lookup(var.cluster_nodes_conf,"ebs_optimized")}"
  root_block_device = {
    volume_type           = "${lookup(var.cluster_nodes_conf,"volume_type")}"
    volume_size           = "${lookup(var.cluster_nodes_conf,"volume_size")}"
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
