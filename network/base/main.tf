data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = "${var.tags}"
}

resource "aws_subnet" "subnet" {
  count             = "${var.subnets_number}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, 4, count.index)}"           # 20(subnet) - 16(vpc) = 4,  2^4 = 16 subnets max / remaining: 2^12 = 4094 hosts per subnet
  vpc_id            = "${aws_vpc.vpc.id}"

  tags = "${var.tags}"
}

resource "aws_internet_gateway" "internet_gw" {
  count  = "${var.with_internet_gw}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${var.tags}"
}

resource "aws_route_table" "all_trafic_route_table" {
  count  = "${var.with_internet_gw}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }
}

resource "aws_route_table_association" "subnet_route_association" {
  count          = "${var.with_internet_gw ? var.subnets_number : 0}"
  subnet_id      = "${aws_subnet.subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.all_trafic_route_table.id}"
}
