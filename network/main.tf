terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "network/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.1"
}

locals {
  owner = "letslearn"
}

module "network_tools" {
  source = "base"

  vpc_cidr_block   = "172.20.0.0/16"
  subnets_number   = "2"
  with_internet_gw = true

  tags = {
    Owner       = "${local.owner}"
    Environment = "${terraform.workspace}"
    Application = "Tools"
  }
}
