resource "aws_instance" "openvpn_server" {
  depends_on                  = ["aws_s3_bucket.certificates"]
  ami                         = "${data.aws_ami.amazon_linux.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.vpn_sg.id}"]
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${data.template_cloudinit_config.cloudinit_template.rendered}"
}

resource "aws_s3_bucket" "certificates" {
  bucket = "${var.owner}-vpn-certificates"
  acl    = "private"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Access-from-VPN-EC2-only"
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.certificates.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.certificates.bucket}/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:sourceIp": "${aws_eip.vpn_static_ip.public_ip}"
        }
      }
    },
    {
      "Sid": "Access-from-Tools-VPC-only"
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:ListObject",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.certificates.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.certificates.bucket}/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:sourceVpc": "${var.vpc_id}"
        }
      }
    }
  ]
}
POLICY

  logging {
    target_bucket = "${aws_s3_bucket.certificates.id}"
    target_prefix = "log/"
  }

  tags {
    Owner       = "${var.owner}"
    Project     = "OpenVPN"
    Environment = "${terraform.workspace}"
  }
}
