terraform {
  backend "s3" {
    bucket = "letslearn-terraform"
    key    = "splunk/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.2"
}

data "aws_availability_zones" "available" {}

data "template_file" "splunk_script_template" {
  template = "./script.sh"
  vars {
    path = "${aws_instance.splunk_instance.ebs_block_device.device_name}"
  }
}

resource "aws_instance" "splunk_instance" {
  ami = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t3.small"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  user_data = "${data.template_file.splunk_script_template.rendered}"

  ebs_block_device {
    device_name = "/dev/sda"
    volume_id = "${aws_ebs_volume.splunk_storage.id}"
  }
}

// TODO: daily snapshot EBS volume - AWS Backup on its way!
// TODO: https://github.com/terraform-providers/terraform-provider-aws/issues/7166
resource "aws_ebs_volume" "splunk_storage" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
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
