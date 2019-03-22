terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "vault/s3/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.3"
}

locals {
  owner = "letslearn"
}

resource "aws_kms_key" "master_key" {
  description             = "Vault master key"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "master_key_alias" {
  name          = "alias/vault-master-key-alias"
  target_key_id = "${aws_kms_key.master_key.key_id}"
}

resource "aws_s3_bucket" "vault_storage" {
  bucket = "${local.owner}-vault-${terraform.workspace}"

  versioning {
    enabled = true
  }

  //  tags {}

  lifecycle {
    create_before_destroy = true
  }
}
