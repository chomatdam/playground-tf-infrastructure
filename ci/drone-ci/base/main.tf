locals {
  drone_domain_name = "drone.${var.domain_name}"
}

data "aws_route53_zone" "main_domain" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "drone_domain" {
  name    = "${local.drone_domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.main_domain.zone_id}"
  ttl     = 5
  records = ["${aws_eip.drone_static_ip.public_ip}"]
}

resource "aws_s3_bucket" "logs_storage" {
  bucket = "${var.owner}-drone-ci-build-logs"
  acl    = "private"
}

resource "random_string" "db_password" {
  length  = 16
  special = false
}

resource "random_string" "rpc_server_client_secret" {
  length  = 16
  special = false
}

resource "aws_eip" "drone_static_ip" {
  instance = "${aws_instance.drone_server.id}"
  vpc      = true
}

resource "aws_instance" "drone_server" {
  associate_public_ip_address = true
  ami                         = "${data.aws_ami.amazon_linux.image_id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_cloudinit_config.user_data.rendered}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.server_sg.id}"]
  subnet_id                   = "${var.server_subnet_id}"
}

resource "aws_security_group" "server_sg" {
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "server_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server_sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]                        // TODO: from VPN ip only
}

resource "aws_security_group_rule" "server_https" {
  description = "Endpoint for users"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server_sg.id}"
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "server_http" {
  description = "Used by acme/autocert to authorize the domain name"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server_sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "template_cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.drone_server_template.rendered}"
  }
}

data "template_file" "drone_server_template" {
  template = "${file("${path.module}/files/init.sh")}"

  vars {
    postgres_username = "${aws_db_instance.default.username}"
    postgres_password = "${random_string.db_password.result}"
    postgres_endpoint = "${aws_db_instance.default.endpoint}"
    postgres_dbname   = "${aws_db_instance.default.name}"

    s3_bucket   = "${aws_s3_bucket.logs_storage.bucket}"
    domain_name = "${local.drone_domain_name}"

    github_oauth_app_client_id     = "${var.github_oauth_app_client_id}"
    github_oauth_app_client_secret = "${var.github_oauth_app_client_secret}"
    drone_rpc_secret               = "${random_string.rpc_server_client_secret.result}"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
