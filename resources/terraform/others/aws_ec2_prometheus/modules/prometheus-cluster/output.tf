output "volumes" {
  value = ["${aws_ebs_volume.prometheus_ebs.*.id}"]
}

output "auto_scaling_groups" {
  value = ["${aws_autoscaling_group.prometheus.*.id}"]
}

output "launch_configurations" {
  value = ["${aws_launch_configuration.launch_config.*.id}"]
}
