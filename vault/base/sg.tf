resource "aws_security_group" "lc_security_group" {
  name_prefix = "${var.owner}-vault-cluster-"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  // TODO: tags {}
}

resource "aws_security_group_rule" "allow_ssh_inbound_from_cidr_blocks" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_api_inbound_from_cidr_blocks" {
  type        = "ingress"
  from_port   = 8200
  to_port     = 8200
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] // TODO: before VPN is there

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self" {
  type      = "ingress"
  from_port = 8201
  to_port   = 8201
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self_api" {
  type      = "ingress"
  from_port = 8200
  to_port   = 8200
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}
