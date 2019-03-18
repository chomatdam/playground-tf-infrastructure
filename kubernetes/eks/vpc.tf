# VPC and subnets
data "aws_availability_zones" "available" {}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = "${merge(
      var.common_tags,
      map("kubernetes.io/cluster/${var.cluster_name}", "shared")
  )}"
}

resource "aws_subnet" "k8s_subnet" {
  count             = "${var.subnets_number}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, 4, count.index)}"           # 20(subnet) - 16(vpc) = 4,  2^4 = 16 subnets max / remaining: 2^12 = 4094 hosts per subnet
  vpc_id            = "${aws_vpc.k8s_vpc.id}"

  tags = "${merge(
      var.common_tags,
      map("kubernetes.io/cluster/${var.cluster_name}", "shared")
  )}"
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.k8s_vpc.id}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table" "all_trafic_route_table" {
  vpc_id = "${aws_vpc.k8s_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }
}

resource "aws_route_table_association" "subnet_route_association" {
  count          = "${var.subnets_number}"
  subnet_id      = "${aws_subnet.k8s_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.all_trafic_route_table.id}"
}
