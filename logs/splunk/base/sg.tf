resource "aws_security_group" "search_head" {
  name_prefix = "letslearn-splunk-"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  TODO: tags {}
}

resource "aws_security_group_rule" "web_interface" {
  from_port         = 8000
  protocol          = "tcp"
  security_group_id = "${aws_security_group.search_head.id}"
  to_port           = 8000
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "key_value_store_replication" {
  from_port         = 8191
  protocol          = "tcp"
  security_group_id = "${aws_security_group.search_head.id}"
  to_port           = 8191
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "search_head_clustering_replication" {
  from_port         = 8090
  protocol          = "tcp"
  security_group_id = "${aws_security_group.search_head.id}"
  to_port           = 8090
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "indexer" {
  name_prefix = "letslearn-splunk-"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  TODO: tags {}
}

resource "aws_security_group_rule" "splunk_tcp" {
  from_port         = 9997
  protocol          = "tcp"
  security_group_id = "${aws_security_group.indexer.id}"
  to_port           = 9997
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                      // TODO: from forwarders
}

resource "aws_security_group_rule" "http_event_collector" {
  from_port         = 8088
  protocol          = "tcp"
  security_group_id = "${aws_security_group.indexer.id}"
  to_port           = 8088
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                      // TODO: from apps
}

resource "aws_security_group_rule" "syslog_tcp" {
  from_port         = 514
  protocol          = "tcp"
  security_group_id = "${aws_security_group.indexer.id}"
  to_port           = 514
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                      // TODO: from apps
}

resource "aws_security_group_rule" "syslog_udp" {
  from_port         = 514
  protocol          = "udp"
  security_group_id = "${aws_security_group.indexer.id}"
  to_port           = 514
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                      // TODO: from apps
}

resource "aws_security_group_rule" "data_replication" {
  from_port         = 9887
  protocol          = "tcp"
  security_group_id = "${aws_security_group.indexer.id}"
  to_port           = 9887
  type              = "ingress"
  self              = true
}

resource "aws_security_group" "splunk" {
  name_prefix = "letslearn-splunk-"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  TODO: tags {}
}

resource "aws_security_group_rule" "ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.splunk.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                     // TODO: VPN
}

resource "aws_security_group_rule" "splunkd_management_port" {
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${aws_security_group.splunk.id}"
  to_port           = 8089
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                     // TODO: VPN
}
