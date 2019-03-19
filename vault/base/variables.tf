variable "owner" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "min_size" {
  type = "string"
}

variable "max_size" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "instance_type" {
  type = "string"
}

variable "key_name" {
  type = "string"
}
