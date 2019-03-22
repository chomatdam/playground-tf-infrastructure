data "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "drone" {
  name = "drone.${var.domain_name}"
  type = "A"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
}
resource "aws_s3_bucket" "logs_storage" {
  bucket = "${var.owner}-drone-ci-build-logs"
  acl = "private"
}

resource "random_string" "db_password" {
  length = 16
  special = true
}

resource "random_string" "rpc_connection_auth_password" {
  length = 16
  special = true
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.1"
  instance_class       = "db.t3.small"
  name                 = "dronedb"
  username             = "drone"
  password             = "${sha256(bcrypt(random_string.db_password))}"
  parameter_group_name = "${aws_db_parameter_group.postgres.name}"
  apply_immediately = true
}

resource "aws_db_parameter_group" "postgres" {
  name = "${var.owner}.${var.project}.postgres11.${terraform.workspace}"
  family = "postgres11"

}

resource "aws_autoscaling_group" "server_asg" {
  max_size = 1
  min_size = 1
  launch_configuration = "${aws_launch_configuration.server_alc.id}"
}

resource "aws_launch_configuration" "server_alc" {
  image_id = "${data.aws_ami.amazon_linux.image_id}"
  instance_type = "${var.instance_type}"
  user_data = "${data.template_cloudinit_config.user_data.rendered}"
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

data "template_cloudinit_config" "user_data" {
  gzip = false
  base64_encode = false // have to be encoded - contains credentials

  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.drone_server_template.rendered}"
  }

}

data "template_file" "drone_server_template" {
  template = "${file("${path.module}/files/init.sh")}"
  vars {
    postgres_username = "${aws_db_instance.default.username}"
    postgres_password = "${aws_db_instance.default.password}"
    postgres_endpoint = "${aws_db_instance.default.endpoint}"
    postgres_dbname   = "${aws_db_instance.default.name}"

    s3_bucket = "${aws_s3_bucket.logs_storage.bucket}"
    domain_name = "${var.domain_name}"

    github_client_id = "82ff6b842906cf2e6618"
    github_client_secret = "d1cc6d6aa4575e165554b13226e4d0e71479705f"
    drone_rpc_secret = "${random_string.rpc_connection_auth_password.result}"

  }
}
