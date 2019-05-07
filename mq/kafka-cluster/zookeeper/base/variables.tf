variable "nb_instances" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "key_name" {
  type = "string"
}

variable "owner" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "listener_port" {
  type    = "string"
  default = 2181
}

variable "jmx_port" {
  type    = "string"
  default = 8989
}
