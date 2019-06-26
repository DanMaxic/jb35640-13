resource "aws_autoscaling_lifecycle_hook" "crushftp_lifecycle_hook" {
  name                    = "crushftp-on-terminate-lifecycle-hook"
  autoscaling_group_name  = "${aws_autoscaling_group.crushftp_asg.name}"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 3600
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
}
