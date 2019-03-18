variable "owner" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "common_tags" {
  type = "map"
}

variable "vpc_cidr_block" {
  type = "string"
}

variable "subnets_number" {
  type = "string"
}

variable "worker_node_instance_type" {
  type = "string"
}

variable "worker_node_min_number" {
  type = "string"
}

variable "worker_node_max_number" {
  type = "string"
}

variable "worker_node_key_pair" {
  type = "string"
}
