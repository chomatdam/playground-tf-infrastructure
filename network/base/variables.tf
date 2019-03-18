variable "tags" {
  type = "map"
}

variable "vpc_cidr_block" {
  type = "string"
}

variable "subnets_number" {
  type = "string"
}

variable "with_internet_gw" {}
