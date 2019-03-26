data "aws_route53_zone" "main_domain" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "drone_domain" {
  name    = "${local.drone_domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.main_domain.zone_id}"
  ttl     = 5
  records = ["${aws_eip.drone_static_ip.public_ip}"]
}

resource "aws_eip" "drone_static_ip" {
  instance = "${aws_instance.drone_server.id}"
  vpc      = true
}
