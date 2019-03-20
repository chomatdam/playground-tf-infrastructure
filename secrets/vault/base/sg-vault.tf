resource "aws_security_group" "vault_cluster_internal" {
  name_prefix = "${var.owner}-vault-cluster-"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  // TODO: tags {}
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self" {
  description = "Forwarded requests between Vault servers"
  type      = "ingress"
  from_port = 8200
  to_port   = 8201
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.vault_cluster_internal.id}"
}

resource "aws_security_group_rule" "allow_api_inbound_from_cidr_blocks" {
  description = "API or web interface traffic"
  type        = "ingress"
  from_port   = 8200
  to_port     = 8200
  protocol    = "tcp"

  security_group_id = "${aws_security_group.vault_cluster_internal.id}"
  source_security_group_id = "${aws_security_group.vault_lb.id}"
}
