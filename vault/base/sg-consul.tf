resource "aws_security_group" "vault_cluster_consul_clients_internal" {
  name_prefix = "${var.owner}-vault-cluster-"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  lifecycle {
    create_before_destroy = true
  }

  // TODO: tags {}
}

resource "aws_security_group_rule" "consul_clients_http_api" {
  description = "This is used by clients to talk to the HTTP API. TCP only."
  type      = "ingress"
  from_port = 8500
  to_port   = 8500
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.vault_cluster_consul_clients_internal.id}"
}

resource "aws_security_group_rule" "consul_clients_dns_interface_tcp" {
  description = "Used to resolve DNS queries. TCP and UDP"
  type      = "ingress"
  from_port = 8600
  to_port   = 8600
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.vault_cluster_consul_clients_internal.id}"
}

resource "aws_security_group_rule" "consul_clients_dns_interface_udp" {
  description = "Used to resolve DNS queries. TCP and UDP"
  type      = "ingress"
  from_port = 8600
  to_port   = 8600
  protocol  = "udp"
  self      = true

  security_group_id = "${aws_security_group.vault_cluster_consul_clients_internal.id}"
}

resource "aws_security_group_rule" "consul_clients_serf_lan_tcp" {
  description = "This is used to handle gossip in the LAN. Required by all agents. TCP and UDP."
  type      = "ingress"
  from_port = 8301
  to_port   = 8301
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.vault_cluster_consul_clients_internal.id}"
}

resource "aws_security_group_rule" "consul_clients_serf_lan_udp" {
  description = "This is used to handle gossip in the LAN. Required by all agents. TCP and UDP."
  type      = "ingress"
  from_port = 8301
  to_port   = 8301
  protocol  = "udp"
  self      = true

  security_group_id = "${aws_security_group.vault_cluster_consul_clients_internal.id}"
}

data "aws_security_group" "consul_server" {
  tags {
    Project = "consul-cluster"
    Type    = "internal"
  }
}

resource "aws_security_group_rule" "consul_client_to_server_tcp" {
  description              = "Allow consul clients to communicate with consul servers"
  type                     = "ingress"
  from_port                = 8300
  to_port                  = 8301
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.vault_cluster_consul_clients_internal.id}"
  security_group_id        = "${data.aws_security_group.consul_server.id}"
}

resource "aws_security_group_rule" "consul_client_to_server_udp" {
  description              = "Allow consul clients to communicate with consul servers"
  type                     = "ingress"
  from_port                = 8300
  to_port                  = 8301
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.vault_cluster_consul_clients_internal.id}"
  security_group_id        = "${data.aws_security_group.consul_server.id}"
}
