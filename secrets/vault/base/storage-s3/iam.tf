data "terraform_remote_state" "vault_s3_state" {
  backend = "s3"

  # Different state file for the storage - we don't want to destroy it if we have to redeploy the cluster from scratch
  config {
    bucket = "letslearn-terraform"
    key    = "vault/s3/state"
    region = "eu-central-1"
  }
}

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

// Attach S3 bucket access to the instance role

resource "aws_iam_role_policy" "vault_s3" {
  name   = "vault_s3"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${element(concat(data.aws_iam_policy_document.s3_bucket_access_policy.*.json, list("")), 0)}"

  lifecycle {
    create_before_destroy = true
  }
}
