data "aws_availability_zones" "current" {}

resource "aws_autoscaling_group" "zookeeper" {
  depends_on                = ["aws_launch_configuration.zookeeper"]
  count                     = "${var.nb_instances}"
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "${element(aws_launch_configuration.zookeeper.*.name, count.index)}"
  max_size                  = 1
  min_size                  = 1
  name                      = "${var.owner}-nb_instances-asg-${count.index}"
  vpc_zone_identifier       = ["${var.subnet_ids[count.index]}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.owner}-zookeeper"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "zookeeper" {
  count                       = "${var.nb_instances}"
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.zookeeper_instance_profile.arn}"
  image_id                    = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  name_prefix                 = "${var.owner}-zookeeper-node-${count.index}"
  security_groups             = ["${aws_security_group.zookeeper_internal.id}", "${aws_security_group.zookeeper_external.id}"]
  user_data                   = "${element(data.template_cloudinit_config.cloudinit_user_data.*.rendered, count.index)}"
  spot_price                  = "0.1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "zookeeper_instance_profile" {
  name = "${var.owner}-zookeeper-profile"
  role = "${aws_iam_role.zookeeper_iam_role.id}"
}

resource "aws_iam_role" "zookeeper_iam_role" {
  name = "${var.owner}-zookeeper-role"

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

data "aws_route53_zone" "selected" {
  name = "${var.domain_name}"
}

//resource "aws_route53_record" "zookeeper_domains" {
//  count   = "${var.nb_instances}"
//  name    = "zookeeper${count.index + 1}.${var.domain_name}"
//  records = ["${element(aws_eip.zookeeper.*.private_ip, count.index)}"]
//  ttl     = "60"
//  type    = "A"
//  zone_id = "${data.aws_route53_zone.selected.zone_id}"
//}

resource "aws_iam_role_policy" "zookeeper_eni" {
  name  = "${var.owner}-zookeeper-eni"
  role = "${aws_iam_role.zookeeper_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AttachNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaceAttribute",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DetachNetworkInterface"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_network_interface" "zookeeper" {
  count = "${var.nb_instances}"
  subnet_id = "${var.subnet_ids[count.index]}"
  security_groups = ["${aws_security_group.zookeeper_internal.id}", "${aws_security_group.zookeeper_external.id}"]

  tags {
    Owner   = "${var.owner}"
    Service = "Zookeeper"
    Node    = "${count.index + 1}"
  }
}

resource "aws_eip" "zookeeper" {
  count             = "${var.nb_instances}"
  depends_on        = ["aws_network_interface.zookeeper"]
  network_interface = "${aws_network_interface.zookeeper.*.id[count.index]}"
  vpc               = true
}
