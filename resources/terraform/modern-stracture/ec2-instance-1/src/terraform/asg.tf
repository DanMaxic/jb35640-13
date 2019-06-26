resource "null_resource" "cluster_instances_asg_tagmap" {
  count     = "${length(keys(var.base_app_tags))}"
  triggers  = "${map(
      "key", "${element(keys(var.base_app_tags), count.index)}",
      "value", "${element(values(var.base_app_tags), count.index)}",
      "propagate_at_launch", true
    )}"
}

locals {
  asg_tags = ["${null_resource.cluster_instances_asg_tagmap.*.triggers}"]
}

/* sftp only */
resource "aws_autoscaling_group" "crushftp_asg" {
  name                  = "${var.deployment_config["application-name"]}-asg"
  max_size              = "${lookup(var.cluster_nodes_conf,"service_cluster_max_size")}"
  min_size              = "${lookup(var.cluster_nodes_conf,"service_cluster_min_size")}"
  desired_capacity      = "${lookup(var.cluster_nodes_conf,"service_cluster_desired_capacity")}"
  termination_policies  = ["OldestLaunchConfiguration"]
  launch_configuration  = "${aws_launch_configuration.crushftp_lc.id}"
  vpc_zone_identifier   = ["${data.terraform_remote_state.vpc_bucket_remote_state_file.public_subnets_ids}"]
  default_cooldown      = 10
  enabled_metrics       = "${var.asg_enabeled_metrics}"
  metrics_granularity   = "1Minute"
  health_check_type     = "EC2"
  load_balancers        = ["${aws_elb.crushftp_elb.name}"]
  target_group_arns     = ["${aws_lb_target_group.crushftp_sftp_target_group.arn}"]
  tags                  = ["${concat(
    list(
      map("key", "Name", "value", "${lookup(var.deployment_config,"application-name")}-asg", "propagate_at_launch", true),
      map("key", "name", "value", "${lookup(var.deployment_config,"application-name")}-asg", "propagate_at_launch", true),
      map("key", "launch-configuration-name", "value", "${aws_launch_configuration.crushftp_lc.name}", "propagate_at_launch", true),
      map("key", "operational-hours", "value", "${lookup(var.cluster_nodes_conf,"operational_hours_tag")}", "propagate_at_launch", true)
    ),
    local.asg_tags)
  }"]
  depends_on = ["null_resource.cluster_instances_asg_tagmap"]
}

/* ftp only */
resource "aws_autoscaling_group" "crushftp_ftp_asg" {
  name                  = "${var.deployment_config["application-name"]}-ftp-asg"
  max_size              = 3
  min_size              = 3
  desired_capacity      = 3
  termination_policies  = ["OldestLaunchConfiguration"]
  launch_configuration  = "${aws_launch_configuration.crushftp_lc.id}"
  vpc_zone_identifier   = ["${data.terraform_remote_state.vpc_bucket_remote_state_file.public_subnets_ids}"]
  default_cooldown      = 10
  enabled_metrics       = "${var.asg_enabeled_metrics}"
  metrics_granularity   = "1Minute"
  health_check_type     = "EC2"
  load_balancers        = ["${aws_elb.crushftp_ftp_elb.name}"]
  target_group_arns     = ["${aws_lb_target_group.crushftp_ftp_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k1_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k2_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k3_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k4_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k5_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k6_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k7_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k8_target_group.arn}",
                           "${aws_lb_target_group.crushftp_ftp_60k9_target_group.arn}"]

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${lookup(var.deployment_config,"application-name")}-ftp-asg", "propagate_at_launch", true),
      map("key", "name", "value", "${lookup(var.deployment_config,"application-name")}-ftp-asg", "propagate_at_launch", true),
      map("key", "launch-configuration-name", "value", "${aws_launch_configuration.crushftp_lc.name}", "propagate_at_launch", true),
      map("key", "operational-hours", "value", "${lookup(var.cluster_nodes_conf,"operational_hours_tag")}", "propagate_at_launch", true)
    ),
    local.asg_tags)
  }"]
  depends_on = ["null_resource.cluster_instances_asg_tagmap"]
}