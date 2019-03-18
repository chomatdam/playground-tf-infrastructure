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

resource "aws_route53_zone" "main" {
  name = "chomat.de"
}
