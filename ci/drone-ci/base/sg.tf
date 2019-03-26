resource "aws_security_group" "server_sg" {
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "server_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server_sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                        // TODO: from VPN ip only
}

resource "aws_security_group_rule" "server_https" {
  description       = "Endpoint for users"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server_sg.id}"
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "server_http" {
  description       = "Used by acme/autocert to authorize the domain name"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server_sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
