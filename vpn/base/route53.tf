data "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "vpn_domain" {
  name    = "vpn.${var.domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  ttl     = 5
  records = ["${aws_eip.vpn.public_ip}"]
}

resource "aws_eip" "vpn" {
  vpc = true
}
