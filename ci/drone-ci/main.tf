terraform {
  backend "s3" {
    bucket  = "letslearn-terraform"
    key     = "drone-ci/state"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.3"
}

module "drone_ci_server" {
  source = "./base"

  instance_type = "t3.small"

  owner            = "letslearn"
  project          = "drone"
  domain_name      = "chomat.de"
  vpc_id           = "${data.aws_vpc.tools.id}"
  server_subnet_id = "${data.aws_subnet_ids.tools_public.ids[0]}"
  db_subnet_ids    = "${data.aws_subnet_ids.tools_db.ids}"
  key_name         = "frankfurt-kitchen"

  github_oauth_app_client_id     = ""
  github_oauth_app_client_secret = ""
}

data "aws_vpc" "tools" {
  tags {
    Name = "tools"
  }
}

// TODO: Drone server is deployed to a public subnet, to be moved to App subnet once VPN available.
data "aws_subnet_ids" "tools_public" {
  vpc_id = "${data.aws_vpc.tools.id}"

  tags {
    Type = "public"
  }
}

data "aws_subnet_ids" "tools_db" {
  vpc_id = "${data.aws_vpc.tools.id}"

  tags {
    Type = "db"
  }
}
