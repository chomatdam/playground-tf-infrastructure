resource "aws_security_group" "worker_node_sg" {
  name        = "${var.owner}-eks-worker-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.k8s_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
      var.common_tags,
      map("kubernetes.io/cluster/${var.cluster_name}", "owned")
  )}"
}

resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.worker_node_sg.id}"
  source_security_group_id = "${aws_security_group.worker_node_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.worker_node_sg.id}"
  source_security_group_id = "${aws_security_group.control_plane_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_node_ssh" {
  cidr_blocks       = ["0.0.0.0/0"]                             # until VPN is deployed
  description       = "Allow to SSH worker nodes"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.worker_node_sg.id}"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.control_plane_sg.id}"
  source_security_group_id = "${aws_security_group.worker_node_sg.id}"
  to_port                  = 443
  type                     = "ingress"
}
