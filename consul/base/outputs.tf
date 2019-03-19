output "consul-dns" {
  value = "${aws_lb.consul_lb.dns_name}"
}