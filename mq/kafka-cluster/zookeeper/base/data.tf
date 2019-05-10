data "template_cloudinit_config" "cloudinit_user_data" {
  count = "${var.nb_instances}"

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudinit_main.*.rendered[count.index]}"
  }
}

data "template_file" "cloudinit_main" {
  count    = "${var.nb_instances}"
  template = "${file("${path.module}/files/init.yaml")}"

  vars {
    docker_compose_file = "${indent(6, data.template_file.zookeeper.*.rendered[count.index])}"
    zk_jaas_file        = "${indent(6, data.template_file.zookeeper_auth_conf.rendered)}"
    attach_eni_file     = "${indent(6, data.template_file.eni_attachment.*.rendered[count.index])}"
  }
}

data "template_file" "eni_attachment" {
  count = "${var.nb_instances}"
  template = "${file("${path.module}/files/templates/attach_eni.sh.tpl")}"

  vars {
    zk_node_number = "${count.index + 1}"
  }
}

data "template_file" "zookeeper" {
  count    = "${var.nb_instances}"
  template = "${file("${path.module}/files/templates/docker-compose.yml.tpl")}"

  vars {
    zk_server_id   = "${count.index + 1}"
    zk_server_port = "${var.listener_port}"
    zk_jmx_port    = "${var.jmx_port}"
    zk_servers    = "${join(";", formatlist("%s:2888:3888", aws_eip.zookeeper.*.private_ip))}" # used for server hostnames  zookeeperX.(domain):XXXX
  }
}

data "template_file" "zookeeper_auth_conf" {
  template = "${file("${path.module}/files/templates/jaas_zk.conf.tpl")}"

  vars {
    super_password     = "${random_string.super_password.result}"
    zookeeper_password = "${random_string.zookeeper_password.result}"
    kafka_password     = "${random_string.kafka_password.result}"
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
