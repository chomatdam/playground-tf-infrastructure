resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.owner}-vault-cluster-"
  role        = "${aws_iam_role.instance_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.owner}-vault-cluster-"
  assume_role_policy = "${data.aws_iam_policy_document.instance_policy.json}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}