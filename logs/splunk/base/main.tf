data "template_file" "splunk_script_template" {
  template = "${file("${path.module}/files/script.sh")}"

  vars {
    path = "${var.ebs_device_name}"
  }
}

data "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "splunk_r53_record" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "splunk.${data.aws_route53_zone.main.name}"
  type    = "A"
  ttl     = 5
  records = ["${aws_eip.splunk_eip.public_ip}"]
}

resource "aws_eip" "splunk_eip" {
  instance = "${aws_instance.splunk_instance.id}"
  vpc      = true
}

resource "aws_instance" "splunk_instance" {
  ami               = "${data.aws_ami.amazon_linux.id}"
  instance_type     = "t3.small"
  availability_zone = "${data.aws_subnet.splunk.availability_zone}"
  user_data         = "${data.template_file.splunk_script_template.rendered}"
  subnet_id         = "${var.subnet_id}"
  key_name          = "frankfurt-kitchen"
  ebs_optimized     = true

  security_groups = [
    "${aws_security_group.splunk.id}",
    "${aws_security_group.search_head.id}",
    "${aws_security_group.indexer.id}",
  ]

  tags {
    Name = "${var.owner}-splunk"
  }
}

resource "aws_volume_attachment" "splunk_ebs_attach" {
  device_name = "${var.ebs_device_name}"
  instance_id = "${aws_instance.splunk_instance.id}"
  volume_id   = "${aws_ebs_volume.splunk_storage.id}"
}

// TODO: daily snapshot EBS volume - AWS Backup on its way!
// TODO: https://github.com/terraform-providers/terraform-provider-aws/issues/7166
resource "aws_ebs_volume" "splunk_storage" {
  availability_zone = "${data.aws_subnet.splunk.availability_zone}"
  size              = 10
}

data "aws_subnet" "splunk" {
  id = "${var.subnet_id}"
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
