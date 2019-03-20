output "consul_dns" {
  value = "${aws_lb.consul_lb.dns_name}"
}

output "consul_cluster_tag_key" {
  value = "${var.consul_node_tag_key}"
}

output "consul_cluster_tag_value" {
  value = "${var.consul_node_tag_value}"
}
