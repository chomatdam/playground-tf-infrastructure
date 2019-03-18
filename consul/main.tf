terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "consul/state"
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

data "aws_route53_zone" "main" {
  name = "chomat.de"
}

module "certificates" {
  source = "../private-tls-cert"

  ca_common_name = "${local.owner}"
  common_name = "${local.owner}"
  dns_names = [ "consul.chomat.de" ]
  organization_name = "${local.owner}"
  owner = "chomatdam"

  ca_public_key_file_path = "${path.module}/packer/ca.crt.pem"

  public_key_file_path = "${path.module}/packer/consul.crt.pem"
  private_key_file_path = "${path.module}/packer/consul.key.pem"

  validity_period_hours = "13140"
}

data "aws_vpc" "tools" {
  tags {
    Application = "Tools"
  }
}

module "consul_cluster" {
  source = "base"

  cluster_name = "${local.owner}-consul-cluster"
  ami_id = "ami-0327b0c1b0a5182ca"

  vpc_id = "${data.aws_vpc.tools.id}"
  ssh_key_name = "frankfurt-kitchen"

  ca_path = "${module.certificates.ca_public_key_file_path}"
  key_file_path = "${module.certificates.private_key_file_path}"
  cert_file_path = "${module.certificates.public_key_file_path}"
}