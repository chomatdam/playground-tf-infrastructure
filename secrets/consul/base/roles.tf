resource "aws_iam_policy" "leader_discovery" {
  name        = "consul-node-leader-discovery"
  path        = "/"
  description = "This policy allows a consul server to discover a consul leader by examining the instances in a consul cluster Auto-Scaling group. It needs to describe the instances in the auto scaling group, then check the IPs of the instances."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups",
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

//  Create a role which consul instances will assume.
//  This role has a policy saying it can be assumed by ec2
//  instances.
resource "aws_iam_role" "consul_instance_role" {
  name = "consul-instance-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "consul-instance-leader-discovery" {
  name       = "consul-instance-leader-discovery"
  roles      = ["${aws_iam_role.consul_instance_role.name}"]
  policy_arn = "${aws_iam_policy.leader_discovery.arn}"
}

//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "consul_instance_profile" {
  name = "consul-instance-profile"
  role = "${aws_iam_role.consul_instance_role.name}"
}
