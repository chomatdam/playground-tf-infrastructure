data "template_cloudinit_config" "cloudinit_template" {
  # Writing needed configuration files (openvpn and easyrsa)
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudinit_template.rendered
  }

  # Script to create CA, server and client cert, launch OpenVPN service
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.script_template.rendered
  }
}

data "template_file" "cloudinit_template" {
  template = file("${path.module}/files/init.yaml")

  vars = {
    vpn_eip_alloc_id         = aws_eip.vpn.id
    openvpn_server_conf_file = indent(6, data.template_file.openvpn_server_conf_template.rendered)
    easyrsa_variables_file   = indent(6, data.template_file.easyrsa_vars_template.rendered)
  }
}

data "template_file" "script_template" {
  template = file("${path.module}/files/script.sh")

  vars = {
    owner       = var.owner
    bucket_name = local.cert_bucket_name
  }
}

# Embedded in cloudinit_template
data "template_file" "openvpn_server_conf_template" {
  template = file("${path.module}/files/server.conf")

  vars = {
    route_value = "${element(split("/", data.aws_vpc.vpn_vpc.cidr_block), 0)}  255.255.240.0"
  }
}

# Embedded in cloudinit_template
data "template_file" "easyrsa_vars_template" {
  template = file("${path.module}/files/vars")

  vars = {
    country  = "US"
    province = "Washington"
    city     = "Seattle"
    owner    = var.owner
    email    = "vpn@${var.domain_name}"
    org_unit = "Infrastructure"
  }
}

data "aws_vpc" "vpn_vpc" {
  id = var.vpc_id
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

