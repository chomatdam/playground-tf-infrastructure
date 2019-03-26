terraform {
  backend "s3" {
    bucket  = "letslearn-terraform"
    key     = "vpn/state"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.3"
}

module "vpn_server" {
  source        = "./base"
  domain_name   = "chomat.de"
  instance_type = "t3.small"
  key_name      = "frankfurt-kitchen"
  owner         = "letslearn"

  vpc_id    = "${data.aws_vpc.tools}"
  subnet_id = "${data.aws_subnet_ids.tools_public.ids[0]}"
}

data "aws_vpc" "tools" {
  tags {
    Name = "tools"
  }
}

data "aws_subnet_ids" "tools_public" {
  vpc_id = "${data.aws_vpc.tools.id}"

  tags {
    Type = "public"
  }
}
