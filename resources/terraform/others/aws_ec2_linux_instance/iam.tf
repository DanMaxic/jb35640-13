data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    sid     = ""
    actions = ["sts:AssumeRole"]

    principals = [
      {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      },
    ]
  }
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    effect = "Allow"
    sid    = ""

    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:GetManifest",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
      "cloudwatch:PutMetricData",
      "ec2:DescribeInstanceStatus",
      "ds:CreateComputer",
      "ds:DescribeDirectories",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "s3:PutObject",
      "s3:GetObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.name}_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "assume_role" {
  name   = "${var.name}_iam_role_policy"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${data.aws_iam_policy_document.policy_document.json}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}_instance_profile"
  role = "${aws_iam_role.instance_role.name}"
}
