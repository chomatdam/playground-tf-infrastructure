resource "random_string" "super_password" {
  length  = 16
  special = true
}

resource "random_string" "zookeeper_password" {
  length  = 16
  special = true
}

resource "random_string" "kafka_password" {
  length  = 16
  special = true
}
