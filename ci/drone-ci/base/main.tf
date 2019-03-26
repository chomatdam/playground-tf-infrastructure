locals {
  drone_domain_name = "drone.${var.domain_name}"
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

resource "aws_instance" "drone_server" {
  associate_public_ip_address = true
  ami                         = "${data.aws_ami.amazon_linux.image_id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_cloudinit_config.user_data.rendered}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.server_sg.id}"]
  subnet_id                   = "${var.server_subnet_id}"

  tags {
    Owner       = "${var.owner}"
    Environment = "${terraform.workspace}"
    Project     = "${var.project}"
  }
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

    github_organization            = "${var.github_organization}"
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
