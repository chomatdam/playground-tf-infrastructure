// Data
data "aws_s3_bucket" "vault_storage" {
  bucket = "${data.terraform_remote_state.vault_s3_state.outputs.vault_bucket_name}"
}

data "aws_iam_policy_document" "s3_bucket_access_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      "${data.aws_s3_bucket.vault_storage.arn}",
      "${data.aws_s3_bucket.vault_storage.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "master_key_decryption_policy" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = ["${data.terraform_remote_state.vault_s3_state.outputs.kms_master_key_id}"]
  }
}

// Attach S3 bucket and master key access to the instance role

resource "aws_iam_role_policy" "vault_s3" {
  name   = "vault_s3"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${element(concat(data.aws_iam_policy_document.s3_bucket_access_policy.*.json, list("")), 0)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "vault_auto_unseal_kms" {
  name   = "vault_auto_unseal_kms"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${element(concat(data.aws_iam_policy_document.master_key_decryption_policy.*.json, list("")), 0)}"

  lifecycle {
    create_before_destroy = true
  }
}
