output "crushftp_elb_name" {
  value = "${aws_elb.crushftp_elb.name}"
}

output "crushftp_elb_dns_name" {
  value = "${aws_elb.crushftp_elb.dns_name}"
}

output "crushftp_elb_sg_id" {
  value = "${aws_security_group.crushftp_elb_sg.id}"
}

output "crushftp_instance_sg_id" {
  value = "${aws_security_group.crushftp_instance_sg.id}"
}

/*
output "crushftp_elb_zone_id" {
  value = "${aws_elb.crushftp_elb.zone_id}"
}

output "crushftp_iam_policy_arn" {
  value = "${aws_iam_policy.crushftp_iam_policy.arn}"
}

output "crushftp_iam_role_arn" {
  value = "${aws_iam_role.crushftp_iam_role.arn}"
}

output "crushftp_instance_profile_arn" {
  value = "${aws_iam_instance_profile.crushftp_instance_profile.arn}"
}
*/