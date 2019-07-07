locals {
  cert_bucket_name = "${var.owner}-vpn-certificates"
}

data "template_file" "client_conf_template" {
  template = file("${path.module}/files/client.ovpn")

  vars = {
    domain_name = var.domain_name
  }
}

resource "aws_s3_bucket_object" "client_conf" {
  bucket  = aws_s3_bucket.certificates.bucket
  key     = "client.ovpn"
  content = data.template_file.client_conf_template.rendered
}

resource "aws_launch_configuration" "launch_configuration" {
  depends_on = [aws_s3_bucket.certificates]

  name_prefix                 = "${var.owner}-vpn-server"
  image_id                    = data.aws_ami.amazon_linux.image_id
  instance_type               = var.instance_type
  user_data                   = data.template_cloudinit_config.cloudinit_template.rendered
  iam_instance_profile        = aws_iam_instance_profile.vpn_instance_profile.name
  key_name                    = var.key_name
  security_groups             = [aws_security_group.vpn_sg.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vpn_asg" {
  name_prefix          = "${var.owner}-vpn-server"
  launch_configuration = aws_launch_configuration.launch_configuration.name
  vpc_zone_identifier  = [var.subnet_id]
  min_size             = 1
  max_size             = 1

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "vpn-server"
    propagate_at_launch = true
  }
}

resource "aws_iam_instance_profile" "vpn_instance_profile" {
  name = "vpn-instance-profile"
  role = aws_iam_role.vpn_iam_role.name
}

resource "aws_iam_role" "vpn_iam_role" {
  name = "vpn-iam-role"

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

resource "aws_iam_policy_attachment" "s3_access_policy_attachment" {
  name = "vpn-s3-access"
  roles = [aws_iam_role.vpn_iam_role.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "vpn-s3-access-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
      "arn:aws:s3:::${local.cert_bucket_name}",
      "arn:aws:s3:::${local.cert_bucket_name}/*"
      ]
    }
  ]
}
POLICY

}

resource "aws_iam_policy_attachment" "eip_association_policy_attachment" {
name       = "vpn-eip-association-access"
roles      = [aws_iam_role.vpn_iam_role.name]
policy_arn = aws_iam_policy.eip_association_policy.arn
}

resource "aws_iam_policy" "eip_association_policy" {
name = "vpn-eip-association-policy"

policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:AssociateAddress",
      "Resource": "*"
    }
  ]
}
POLICY

}

resource "aws_s3_bucket" "certificates_logs" {
bucket = "${local.cert_bucket_name}-logs"
acl = "log-delivery-write"
force_destroy = true
}

resource "aws_s3_bucket" "certificates" {
bucket = local.cert_bucket_name
acl = "private"

logging {
target_bucket = aws_s3_bucket.certificates_logs.bucket
target_prefix = "logs/"
}

tags = {
Owner = var.owner
Project = "OpenVPN"
Environment = terraform.workspace
}
}

//resource "aws_s3_bucket_policy" "cert_restricted_access" {
//  bucket = "${local.cert_bucket_name}"
//  policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Sid": "Access-from-Tools-VPC-only",
//      "Effect": "Allow",
//      "Principal": "*",
//      "Action": "s3:ListBucket",
//      "Resource": [
//        "arn:aws:s3:::${local.cert_bucket_name}",
//        "arn:aws:s3:::${local.cert_bucket_name}/*"
//      ],
//      "Condition": {
//        "StringEquals": {
//          "aws:sourceVpc": "${var.vpc_id}"
//        }
//      }
//    },
//    {
//      "Sid": "Access-from-Root-only",
//      "Effect": "Allow",
//      "Action": "s3:*",
//      "Principal": {
//        "AWS": [
//            "arn:aws:iam::743683729036:root",
//            "arn:aws:iam::743683729036:user/damien.chomat",
//            "${aws_iam_role.vpn_instance_role.arn}"
//            ]
//      },
//      "Resource": [
//        "arn:aws:s3:::${local.cert_bucket_name}",
//        "arn:aws:s3:::${local.cert_bucket_name}/*"
//      ]
//    }
//  ]
//}
//POLICY
//}
