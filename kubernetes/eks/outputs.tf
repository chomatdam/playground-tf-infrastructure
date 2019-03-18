output "cluster_name" {
  value = "${aws_eks_cluster.eks.name}"
}

output "endpoint" {
  value = "${aws_eks_cluster.eks.endpoint}"
}

output "kubeconfig_certificate_authority_data" {
  value = "${aws_eks_cluster.eks.certificate_authority.0.data}"
}

output "worker_node_iam_role_arn" {
  value = "${aws_iam_role.worker_node_iam_role.arn}"
}
