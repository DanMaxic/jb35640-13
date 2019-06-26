resource "aws_autoscaling_policy" "crushftp_asg_scale_out_policy" {
  name                    = "crushftp_asg_scale_out_policy"
  scaling_adjustment      = 1
  policy_type             = "SimpleScaling"
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "${aws_autoscaling_group.crushftp_asg.name}"
}

resource "aws_autoscaling_policy" "crushftp_asg_scale_in_policy" {
  name                    = "crushftp_asg_scale_in_policy"
  scaling_adjustment      = -1
  policy_type             = "SimpleScaling"
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "${aws_autoscaling_group.crushftp_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "crushftp_cpu_scale_out_alarm" {
  alarm_name              = "crushftp_cpu_scale_out_alarm"
  comparison_operator     = "GreaterThanOrEqualToThreshold"
  evaluation_periods      = "2"
  metric_name             = "CPUUtilization"
  namespace               = "AWS/EC2"
  period                  = "60"
  statistic               = "Average"
  threshold               = "60"
  dimensions {
    AutoScalingGroupName  = "${aws_autoscaling_group.crushftp_asg.name}"
  }
  alarm_description       = "This metric monitors ec2 cpu utilization"
  alarm_actions           = ["${aws_autoscaling_policy.crushftp_asg_scale_out_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "crushftp_cpu_scale_in_alarm" {
  alarm_name              = "crushftp_cpu_scale_in_alarm"
  comparison_operator     = "LessThanOrEqualToThreshold"
  evaluation_periods      = "2"
  metric_name             = "CPUUtilization"
  namespace               = "AWS/EC2"
  period                  = "60"
  statistic               = "Average"
  threshold               = "10"
  dimensions {
    AutoScalingGroupName  = "${aws_autoscaling_group.crushftp_asg.name}"
  }
  alarm_description       = "This metric monitors ec2 cpu utilization"
  alarm_actions           = ["${aws_autoscaling_policy.crushftp_asg_scale_in_policy.arn}"]
}
