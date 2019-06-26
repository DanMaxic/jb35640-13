data "template_file" "crushftp_policy_json" {
  template = "${file("${path.module}/templates/crushftp_iam_policy.json")}"
  vars {
    s3_data_bucket    = "${aws_s3_bucket.s3_data_bucket.bucket}"
    s3_config_bucket  = "${aws_s3_bucket.s3_config_bucket.bucket}"
  }
}

resource "aws_iam_policy" "crushftp_iam_policy" {
  name   = "crushftp-iam-policy"
  policy = "${data.template_file.crushftp_policy_json.rendered}"
}

resource "aws_iam_role" "crushftp_iam_role" {
  name                = "crushftp-iam-role"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role        = "${aws_iam_role.crushftp_iam_role.name}"
  policy_arn  = "${aws_iam_policy.crushftp_iam_policy.arn}"
}

resource "aws_iam_instance_profile" "crushftp_instance_profile" {
  name = "crushftp-iam-instance-profile"
  role = "${aws_iam_role.crushftp_iam_role.name}"
}