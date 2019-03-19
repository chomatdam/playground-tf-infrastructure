variable "key_name" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "node_instance_type" {
  type = "string"
}

variable "min_size" {
  type = "string"
}

variable "max_size" {
  type = "string"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "asg_name" {
  default = "consul-cluster-asg"
  type    = "string"
}

variable "consul_version" {
  type = "string"
}

# Way for consul instances to discover each other (part to improve)
variable "consul_node_tag_key" {
  default = "Name"
  type = "string"
}
variable "consul_node_tag_value" {
  default = "cluster-node"
  type = "string"
}

