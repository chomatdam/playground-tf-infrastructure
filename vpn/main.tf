terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "letslearn-terraform"
    key     = "vpn/state"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-west-3"
  version = "~> 2.18"
}

module "vpn_server" {
  source        = "./base"
  domain_name   = "chomat.de"
  instance_type = "t2.micro"
  key_name      = "aws-eu-west-3"
  owner         = "letslearn"

  vpc_id    = data.aws_vpc.tools.id
  subnet_id = tolist(data.aws_subnet_ids.tools_public.ids)[0]
}

data "aws_vpc" "tools" {
  tags = {
    Name = "tools"
  }
}

data "aws_subnet_ids" "tools_public" {
  vpc_id = data.aws_vpc.tools.id

  tags = {
    Type = "public"
  }
}

