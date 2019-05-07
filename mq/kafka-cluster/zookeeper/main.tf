terraform {
  backend "s3" {
    bucket  = "letslearn-terraform"
    key     = "zookeeper/state"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.3"
}

module "zookeeper_cluster" {
  source = "base"

  owner       = "letslearn"
  domain_name = "chomat.de"

  nb_instances  = "2"
  instance_type = "t2.small"

  key_name = "frankfurt-kitchen"

  vpc_id     = "${data.aws_vpc.tools.id}"
  subnet_ids = "${data.aws_subnet_ids.tools_app.ids}"
}

data "aws_vpc" "tools" {
  tags {
    Name = "tools"
  }
}

data "aws_subnet_ids" "tools_app" {
  vpc_id = "${data.aws_vpc.tools.id}"

  tags {
    Type = "public"
  }
}
