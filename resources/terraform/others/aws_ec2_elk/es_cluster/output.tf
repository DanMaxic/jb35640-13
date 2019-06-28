output "volumes" {
  value = ["${aws_ebs_volume.elastic_ebs.*.id}"]
}

output "auto_scaling_groups" {
  value = ["${aws_autoscaling_group.elastic.*.id}"]
}

output "launch_configurations" {
  value = ["${aws_launch_configuration.launch_config.*.id}"]
}

output "security_groups" {
  value = ["${aws_security_group.allow_es_inbound.*.id}"]
}

output "dns_name" {
  value = "${aws_alb.es_alb.dns_name}"
}
