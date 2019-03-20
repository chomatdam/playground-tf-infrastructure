terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "splunk/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.2"
}

locals {
  device_name = "/dev/sdf"
}

module "splunk" {
  source = "base"

  owner = "letslearn"

  vpc_id    = "${data.aws_vpc.tools.id}"
  subnet_id = "${data.aws_subnet.tools_public.id}"

  domain_name     = "chomat.de"
  ebs_device_name = "/dev/sdf"
}

// Network
data "aws_availability_zones" "available" {}

data "aws_vpc" "tools" {
  tags {
    Name = "tools"
  }
}

data "aws_subnet" "tools_public" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id            = "${data.aws_vpc.tools.id}"

  tags {
    Type = "public"
  }
}
