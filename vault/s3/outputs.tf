output "vault_bucket_name" {
  value = "${aws_s3_bucket.vault_storage.bucket}"
}

output "kms_master_key_id" {
  value = "${aws_kms_alias.master_key_alias.target_key_id}"
}
