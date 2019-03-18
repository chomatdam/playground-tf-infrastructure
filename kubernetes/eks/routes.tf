data "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

resource "aws_route53_zone" "k8s_subdomain" {
  name = "k8s.${var.domain_name}"
}

resource "aws_route53_record" "k8s_ns" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${aws_route53_zone.k8s_subdomain.name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.k8s_subdomain.name_servers.0}",
    "${aws_route53_zone.k8s_subdomain.name_servers.1}",
    "${aws_route53_zone.k8s_subdomain.name_servers.2}",
    "${aws_route53_zone.k8s_subdomain.name_servers.3}",
  ]
}
