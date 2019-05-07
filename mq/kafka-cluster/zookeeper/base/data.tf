data "template_cloudinit_config" "cloudinit_user_data" {
  count = "${var.nb_instances}"

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudinit_main.*.rendered[count.index]}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.script_template.rendered}"
  }
}

data "template_file" "script_template" {
  template = "${file("${path.module}/files/script.sh")}"

  vars {
    owner = "${var.owner}"
  }
}

data "template_file" "cloudinit_main" {
  count    = "${var.nb_instances}"
  template = "${file("${path.module}/files/init.yaml")}"

  vars {
    zk_jaas_file        = "${indent(6, data.template_file.zookeeper_jaas.rendered)}"
    docker_compose_file = "${indent(6, data.template_file.docker_compose.*.rendered[count.index])}"
  }
}

data "template_file" "zookeeper_jaas" {
  template = "${file("${path.module}/files/templates/jaas_zk.conf.tpl")}"

  vars {
    super_password     = "${random_string.super_password.result}"
    zookeeper_password = "${random_string.zookeeper_password.result}"
    kafka_password     = "${random_string.kafka_password.result}"
  }
}

data "template_file" "docker_compose" {
  count    = "${var.nb_instances}"
  template = "${file("${path.module}/files/templates/docker-compose.yml.tpl")}"

  vars {
    zk_server_id   = "${count.index}"
    zk_server_port = "${var.listener_port}"
    zk_jmx_port    = "${var.jmx_port}"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
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
