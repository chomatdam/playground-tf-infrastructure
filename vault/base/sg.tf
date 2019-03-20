resource "aws_security_group" "vault_cluster_public" {
  name_prefix = "${var.owner}-vault-cluster-"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  // TODO: tags {}
}

resource "aws_security_group_rule" "allow_ssh_inbound_from_cidr_blocks" {
  description = "SSH from defined cidr blocks"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vault_cluster_public.id}"
}
