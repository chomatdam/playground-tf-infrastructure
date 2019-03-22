terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "kubernetes/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.3"
}

locals {
  owner = "letslearn"
}

resource "aws_s3_bucket" "s3_certificates_k8s" {
  bucket = "${local.owner}-certificates-k8s" // TODO: not used yet - place to push the kubeconfig
  acl    = "private"
}

module "eks_cluster" {
  source = "eks"

  owner        = "${local.owner}"
  cluster_name = "${local.owner}-cluster-${terraform.workspace}"
  domain_name  = "chomat.de"

  vpc_cidr_block = "172.30.0.0/16"
  subnets_number = "2"

  worker_node_key_pair      = "frankfurt-kitchen"
  worker_node_instance_type = "t3.small"
  worker_node_min_number    = "1"
  worker_node_max_number    = "3"

  common_tags = {
    Owner       = "${local.owner}"
    Environment = "${terraform.workspace}"
  }
}

data "template_file" "kubeconfig_template" {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"

  vars {
    cluster_endpoint = "${module.eks_cluster.endpoint}"
    cluster_ca       = "${module.eks_cluster.kubeconfig_certificate_authority_data}"
    cluster_name     = "${module.eks_cluster.cluster_name}"
  }
}

resource "local_file" "kubeconfig_file" {
  content  = "${data.template_file.kubeconfig_template.rendered}"
  filename = "${path.module}/config/config"
}

data "template_file" "config_map_aws_auth_template" {
  template = "${file("${path.module}/templates/config_map_aws_auth.yaml.tpl")}"

  vars {
    arn_value = "${module.eks_cluster.worker_node_iam_role_arn}"
  }
}

resource "local_file" "config_map_aws_auth_file" {
  content  = "${data.template_file.config_map_aws_auth_template.rendered}"
  filename = "${path.module}/config/config_map_aws_auth.yaml"
}
