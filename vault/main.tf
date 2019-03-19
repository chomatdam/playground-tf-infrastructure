terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "vault/cluster/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.1"
}

module "vault_cluster" {
  source = "base"

  owner    = "letslearn"
  key_name = "frankfurt-kitchen"

  instance_type = "t3.small"
  min_size      = "1"
  max_size      = "3"

  vpc_id     = "${data.aws_vpc.vault_vpc.id}"
  subnet_ids = "${data.aws_subnet_ids.vault_public_subnet_ids.ids}"
}

// Data
data "aws_vpc" "vault_vpc" {
  tags {
    Name = "tools"
  }
}

data "aws_subnet_ids" "vault_public_subnet_ids" {
  vpc_id = "${data.aws_vpc.vault_vpc.id}"

  tags {
    Environment = "${terraform.workspace}"
    Type        = "public"
  }
}
