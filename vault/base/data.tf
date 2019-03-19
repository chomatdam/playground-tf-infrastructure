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

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data-vault.sh")}"

  vars {
    aws_region = "${data.aws_region.current.name}"
    kms_key_id = "${aws_kms_alias.master_key_alias.target_key_id}}"
    kms_endpoint = "https://kms.${data.aws_region.current}.amazonaws.com"

    consul_version = "${var.consul_version}"
    consul_cluster_tag_key   = "${data.terraform_remote_state.consul_state.outputs.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${data.terraform_remote_state.consul_state.outputs.consul_cluster_tag_value}"

    vault_version = "${var.vault_version}"
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
