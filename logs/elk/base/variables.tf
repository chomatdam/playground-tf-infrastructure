variable "domain_name" {
  type = "string"
}

variable "elasticsearch_version" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "instance_count" {
  type = "string"
}

variable "dedicated_master_count" {
  type = "string"
}

variable "dedicated_master_type" {
  type = "string"
}

variable "zone_awareness_enabled" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "ebs_volume_size" {
  type = "string"
}

variable "ebs_volume_type" {
  type = "string"
}
