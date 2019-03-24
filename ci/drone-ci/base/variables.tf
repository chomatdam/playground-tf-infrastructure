variable "instance_type" {
  type = "string"
}

variable "owner" {
  type = "string"
}

variable "project" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "server_subnet_id" {
  type = "string"
}

variable "db_subnet_ids" {
  type = "list"
}

variable "key_name" {
  type = "string"
}

variable "github_oauth_app_client_id" {
  type = "string"
}

variable "github_oauth_app_client_secret" {
  type = "string"
}
