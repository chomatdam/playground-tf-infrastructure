data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "consul_state" {
  backend = "s3"

  config {
    bucket = "letslearn-terraform"
    key    = "consul/state"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "vault_s3_state" {
  backend = "s3"

  config {
    bucket = "letslearn-terraform"
    key    = "vault/s3/state"
    region = "eu-central-1"
  }
}

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data-vault.sh")}"

  vars {
    consul_cluster_tag_key   = "${data.terraform_remote_state.consul_state.outputs.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${data.terraform_remote_state.consul_state.outputs.consul_cluster_tag_value}"

    kms_key_id = "${data.terraform_remote_state.vault_s3_state.outputs.kms_master_key_id}}"
    aws_region = "${data.aws_region.current.name}"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
