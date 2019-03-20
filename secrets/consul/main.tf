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

// Resources
resource "aws_s3_bucket" "s3_certificates_consul" {
  bucket = "letslearn-certificates-consul" // TODO: not used yet - iteration 2 for encryption
  acl    = "private"
}

module "consul_cluster" {
  source = "base"

  key_name       = "frankfurt-kitchen"
  consul_version = "1.4.3"

  node_instance_type = "t3.small"
  min_size           = "2"
  max_size           = "3"

  vpc_id            = "${data.aws_vpc.consul_vpc.id}"
  public_subnet_ids = "${data.aws_subnet_ids.consul_public_subnet_ids.ids}"
}

// Data
data "aws_vpc" "consul_vpc" {
  tags {
    Name = "tools"
  }
}

data "aws_subnet_ids" "consul_public_subnet_ids" {
  vpc_id = "${data.aws_vpc.consul_vpc.id}"

  tags {
    Environment = "${terraform.workspace}"
    Type        = "public"
  }
}
