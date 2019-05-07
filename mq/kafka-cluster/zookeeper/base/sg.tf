resource "aws_security_group" "zookeeper_external" {
  name   = "${var.owner}-zookeeper-external"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.owner}-zookeeper"
  }
}

resource "aws_security_group_rule" "ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.zookeeper_external.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "listener_port" {
  description       = "Zookeeper port by different nodes"
  from_port         = "${var.listener_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.zookeeper_external.id}"
  to_port           = "${var.listener_port}"
  type              = "ingress"
  self              = true
}

resource "aws_security_group" "zookeeper_internal" {
  name   = "${var.owner}-zookeeper-internal"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.owner}-zookeeper"
  }
}

resource "aws_security_group_rule" "zookeeper_inter_node_1" {
  description       = "Zookeeper port by different nodes"
  from_port         = "2888"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.zookeeper_internal.id}"
  to_port           = "2888"
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper_inter_node_2" {
  description       = "Zookeeper port by different nodes"
  from_port         = "3888"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.zookeeper_internal.id}"
  to_port           = "3888"
  type              = "ingress"
  self              = true
}
