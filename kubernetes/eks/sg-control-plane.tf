resource "aws_security_group" "control_plane_sg" {
  name        = "${var.owner}-eks-control-plane"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.k8s_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${var.common_tags}"
}

# Remote access:   laptop -> control plane over HTTPS
resource "aws_security_group_rule" "restricted_https" {
  //  cidr_blocks       = ["${var.inbound_cidr_blocks["Office"]}", "${var.inbound_cidr_blocks["Home"]}"] # until VPN is deployed
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.control_plane_sg.id}"
  to_port           = 443
  type              = "ingress"
}
