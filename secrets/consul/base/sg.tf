resource "aws_security_group" "consul_cluster_internal" {
  name        = "consul-cluster-vpc"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags {
    Name    = "Consul Cluster Internal"
    Project = "consul-cluster"
    Type    = "internal"
  }
}
resource "aws_security_group_rule" "consul_server_node_local_allow_all_in" {
  description = "Allow all traffic in"
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  self = true

  security_group_id = "${aws_security_group.consul_cluster_internal.id}"
}

resource "aws_security_group" "consul_cluster_public" {
  name        = "consul-cluster-public"
  description = "Security group that allows SSH traffic and access to UI from internet"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name    = "Consul Cluster Public"
    Project = "consul-cluster"
    Type    = "public"
  }
}

resource "aws_security_group_rule" "allow_ssh_inbound_from_cidr_blocks" {
  description = "SSH from defined cidr blocks"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] // TODO: change when VPN

  security_group_id = "${aws_security_group.consul_cluster_public.id}"
}

resource "aws_security_group_rule" "consul_server_node_allow_http_in" {
  description = "Allow HTTP"
  type        = "ingress"
  from_port   = 8500
  to_port     = 8500
  protocol    = "tcp"

  security_group_id = "${aws_security_group.consul_cluster_public.id}"
  source_security_group_id = "${aws_security_group.consul_cluster_lb_public.id}"
}

resource "aws_security_group" "consul_cluster_lb_public" {
  name        = "consul-cluster-lb-public"
  description = "Security group that allows HTTP to lb"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "Consul Cluster Public Load Balancer"
    Project = "consul-cluster"
    Type    = "public"
  }
}

resource "aws_security_group_rule" "consul_server_lb_allow_http_in" {
  description = "Allow HTTP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] // TODO: change when VPN

  security_group_id = "${aws_security_group.consul_cluster_lb_public.id}"
}
