variable "extra_tags" {
  type = "map"
  default = {}
}

variable "owner" {
  type = "string"
}

variable "vpc_name" {
  type = "string"
}

variable "vpc_cidr_block" {
  type = "string"
}

variable "avaibility_zones_number" {
  type = "string"
}

variable "db_subnet_enabled" {
  default = true
  type = "string"
}
