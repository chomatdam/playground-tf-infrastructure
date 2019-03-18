# Control plane
resource "aws_eks_cluster" "eks" {
  name     = "${var.owner}-cluster-${terraform.workspace}"
  role_arn = "${aws_iam_role.eks_cluster_iam_role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.control_plane_sg.id}"]
    subnet_ids         = ["${aws_subnet.k8s_subnet.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy",
  ]
}

# Worker node
data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_region" "current" {}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${aws_eks_cluster.eks.name}'
USERDATA
}

resource "aws_launch_configuration" "alc" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.worker_node_instance_profile.name}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  instance_type               = "${var.worker_node_instance_type}"
  name_prefix                 = "${var.owner}-eks-worker-node"
  security_groups             = ["${aws_security_group.worker_node_sg.id}"]
  user_data_base64            = "${base64encode(local.node-userdata)}"
  key_name                    = "${var.worker_node_key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = "${var.worker_node_min_number}"
  launch_configuration = "${aws_launch_configuration.alc.id}"
  min_size             = "${var.worker_node_min_number}"
  max_size             = "${var.worker_node_max_number}"
  name                 = "instance"
  vpc_zone_identifier  = ["${aws_subnet.k8s_subnet.*.id}"]

  tags = [
    {
      key                 = "Owner"
      value               = "${var.owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${terraform.workspace}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "eks-worker-node"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
  ]
}
