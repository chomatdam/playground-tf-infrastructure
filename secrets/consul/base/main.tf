// Data
data "aws_region" "current" {}

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

// Resources
data "template_cloudinit_config" "consul_instance_data" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "consul-node.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.consul_script.rendered}"
  }
}

data "template_file" "consul_script" {
  template = "${file("${path.module}/files/consul-node.sh")}"

  vars {
    asgname        = "${var.asg_name}"
    region         = "${data.aws_region.current.name}"
    size           = "${var.min_size}"
    consul_version = "${var.consul_version}"
    node_tag_key   = "${var.consul_node_tag_key}"
    node_tag_value = "${var.consul_node_tag_value}"
  }
}

resource "aws_lb" "consul_lb" {
  name               = "consul-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = ["${aws_security_group.consul_cluster_lb_public.id}"]

  subnets = ["${var.public_subnet_ids}"]

  // TODO: tags
}

resource "aws_lb_target_group" "consul_lb_tg" {
  name        = "consul-lb-tg"
  port        = 8500
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/ui/"
    interval            = 30
  }

  // TODO: tags
}

resource "aws_lb_listener" "consul_lb_listener" {
  load_balancer_arn = "${aws_lb.consul_lb.arn}"
  protocol          = "HTTP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.consul_lb_tg.arn}"
  }
}

resource "aws_launch_configuration" "consul_cluster_lc" {
  name_prefix                 = "consul-node-"
  image_id                    = "${data.aws_ami.amazon_linux.image_id}"
  instance_type               = "${var.node_instance_type}"
  user_data                   = "${data.template_cloudinit_config.consul_instance_data.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.consul_instance_profile.id}"
  associate_public_ip_address = true                                                              // optional, managed at subnet level

  security_groups = [
    "${aws_security_group.consul_cluster_internal.id}",
    "${aws_security_group.consul_cluster_public.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  key_name = "${var.key_name}"
}

resource "aws_autoscaling_group" "consul_cluster_asg" {
  depends_on           = ["aws_launch_configuration.consul_cluster_lc", "aws_lb.consul_lb"]
  name                 = "${var.asg_name}"
  launch_configuration = "${aws_launch_configuration.consul_cluster_lc.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  vpc_zone_identifier  = ["${var.public_subnet_ids}"]
  target_group_arns    = ["${aws_lb_target_group.consul_lb_tg.arn}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "${var.consul_node_tag_key}"
    value               = "${var.consul_node_tag_value}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "consul-cluster"
    propagate_at_launch = true
  }
}
