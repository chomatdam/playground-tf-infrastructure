resource "aws_kms_key" "master_key" {
  description             = "Vault master key"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "master_key_alias" {
  name          = "alias/vault-master-key-alias"
  target_key_id = "${aws_kms_key.master_key.key_id}"
}

data "aws_iam_policy_document" "master_key_decryption_policy" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = ["${aws_kms_key.master_key.arn}"]
  }
}

resource "aws_iam_role_policy" "vault_auto_unseal_kms" {
  name   = "vault-auto-unseal-kms"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${data.aws_iam_policy_document.master_key_decryption_policy.json}"

  lifecycle {
    create_before_destroy = true
  }
}
