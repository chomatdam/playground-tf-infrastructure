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

resource "aws_route53_zone" "main" {
  name = "chomat.de"
}

module "network_tools" {
  source = "base"

  owner                   = "${local.owner}"
  vpc_name                = "tools"
  vpc_cidr_block          = "172.20.0.0/16"
  avaibility_zones_number = "2"
  db_subnet_enabled       = false

  extra_tags = {}
}
