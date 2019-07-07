resource "aws_security_group" "vpn_sg" {
  name   = "openvpn_sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vpn_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "openvpn_udp" {
  from_port         = 1194
  protocol          = "udp"
  security_group_id = aws_security_group.vpn_sg.id
  to_port           = 1194
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

