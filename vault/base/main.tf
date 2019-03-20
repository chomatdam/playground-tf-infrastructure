data "template_cloudinit_config" "user_data" {
  base64_encode = false
  gzip          = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudinit_config.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.user_data_vault_cluster.rendered}"
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${var.owner}-vault-cluster-"
  image_id      = "${data.aws_ami.amazon_linux.image_id}"
  instance_type = "${var.instance_type}"
  user_data     = "${data.template_cloudinit_config.user_data.rendered}"

  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  key_name                    = "${var.key_name}"
  security_groups             = [
    "${aws_security_group.vault_cluster_public.id}",
    "${aws_security_group.vault_cluster_internal.id}",
    "${aws_security_group.vault_cluster_consul_clients_internal.id}"
  ]
  associate_public_ip_address = true                                                // Already set by the subnet

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vault_asg" {
  name_prefix = "${var.owner}-vault-cluster-"

  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"
  target_group_arns    = ["${aws_lb_target_group.vault_lb_tg.arn}"]

  availability_zones  = ["${data.aws_availability_zones.available.names}"]
  vpc_zone_identifier = ["${var.subnet_ids}"]

  min_size         = "${var.min_size}"
  max_size         = "${var.max_size}"
  desired_capacity = "${var.min_size}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "vault-server"
    propagate_at_launch = true
  }
}
