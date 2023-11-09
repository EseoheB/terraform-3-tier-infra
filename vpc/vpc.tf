resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-VPC"}, var.tags)
}

resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone[0]

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet1"}, var.tags)
}

resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone[1]

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet2"}, var.tags)
}

resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet1_cidr
  availability_zone = var.availability_zone[0]

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet1"}, var.tags)
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet2_cidr
  availability_zone = var.availability_zone[1]

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet2"}, var.tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-IGW"}, var.tags)
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"}, var.tags)
}

resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "eip" {
  domain   = "vpc"

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip"}, var.tags)
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw"}, var.tags)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip, aws_subnet.public_subnet1]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge({Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt"}, var.tags)
}

resource "aws_route_table_association" "private_subnet1_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet2_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}