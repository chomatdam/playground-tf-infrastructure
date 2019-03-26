// Auto-join Consul feature
resource "aws_iam_policy_attachment" "cluster_discovery" {
  name       = "consul-node-policy-attachment"
  roles      = ["${aws_iam_role.instance_role.name}"]
  policy_arn = "${aws_iam_policy.cluster_discovery.arn}"
}

resource "aws_iam_policy" "cluster_discovery" {
  name        = "consul-node-policy"
  path        = "/"
  description = "This policy allows to describe instances to join the cluster by IPs based on tags"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
    EOF
}
