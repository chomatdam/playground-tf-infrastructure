terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "splunk/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.3"
}

module "drone_ci_server" {
  source = "./base"

  instance_type = "t3.small"

  owner = "letslearn"
  project = "drone"
  domain_name = "chonat.de"
}