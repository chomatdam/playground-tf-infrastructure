terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "s3/state"
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

resource "aws_s3_bucket" "s3_certificates_k8s" {
  bucket = "${var.owner}-certificates-k8s"
  acl    = "private"
}

resource "aws_s3_bucket" "s3_certificates_vpn" {
  bucket = "${var.owner}-certificates-vpn"
  acl    = "private"
}

resource "aws_s3_bucket" "s3_certificates_consul" {
  bucket = "${var.owner}-certificates-consul"
  acl    = "private"
}

resource "aws_s3_bucket" "s3_certificates_vault" {
  bucket = "${var.owner}-certificates-vault"
  acl    = "private"
}
