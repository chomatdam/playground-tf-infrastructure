data "aws_availability_zones" "available" {}

locals {
  common_tags = {
    Owner       = "${var.owner}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = "${merge(local.common_tags, var.extra_tags, map("Name", "${var.vpc_name}"))}"
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(local.common_tags, var.extra_tags)}"
}

# cidrsubnet: 20(subnet) - 16(vpc) = 4,  2^4 = 16 subnets max / remaining: 2^12 = 4094 hosts per subnet
resource "aws_subnet" "public" {
  count                   = "${var.avaibility_zones_number}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 4, count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true

  tags = "${merge(local.common_tags, var.extra_tags, map(
  "Name", join("-", list(var.vpc_name, terraform.workspace, "public")),
  "Type", "public"
  ))}"
}

resource "aws_route_table" "all_trafic_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }
}

resource "aws_route_table_association" "public_subnet_route_association" {
  count          = "${var.avaibility_zones_number}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.all_trafic_route_table.id}"
}

// App subnet
resource "aws_subnet" "app" {
  count                   = "${var.avaibility_zones_number}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 4, (1 * var.avaibility_zones_number) + count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false

  tags = "${merge(local.common_tags, var.extra_tags, map(
  "Name", join("-", list(var.vpc_name, terraform.workspace, "app")),
  "Type", "app"
  ))}"
}

// DB subnet
resource "aws_subnet" "db" {
  count                   = "${var.avaibility_zones_number}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 4, (2 * var.avaibility_zones_number) + count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false

  tags = "${merge(local.common_tags, var.extra_tags, map(
  "Name", join("-", list(var.vpc_name, terraform.workspace, "db")),
  "Type", "db"
  ))}"
}

resource "aws_eip" "db_nat_eip" {
  count = "${var.avaibility_zones_number}"
  vpc   = true

  tags = "${merge(local.common_tags, var.extra_tags, map(
  "Name", join("-", list(var.vpc_name, terraform.workspace, "db")),
  "Project", "NAT Gateway",
  "Type", "db"
  ))}"
}

resource "aws_nat_gateway" "db_nat_gw" {
  count         = "${var.avaibility_zones_number}"
  allocation_id = "${aws_eip.db_nat_eip.*.id[count.index]}"
  subnet_id     = "${aws_subnet.db.*.id[count.index]}"

  tags = "${merge(local.common_tags, var.extra_tags, map(
  "Name", join("-", list(var.vpc_name, terraform.workspace, "db")),
  "Project", "NAT Gateway",
  "Type", "db"
  ))}"
}

resource "aws_route_table" "db_route_table" {
  count  = "${var.avaibility_zones_number}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.db_nat_gw.*.id[count.index]}"
  }

  tags = "${merge(local.common_tags, var.extra_tags, map(
  "Name", join("-", list(var.vpc_name, terraform.workspace, "db")),
  "Project", "NAT Gateway",
  "Type", "db"
  ))}"
}

resource "aws_route_table_association" "db_route_nat_gw" {
  count          = "${var.avaibility_zones_number}"
  route_table_id = "${aws_route_table.db_route_table.*.id[count.index]}"
  subnet_id      = "${aws_subnet.db.*.id[count.index]}"
}
