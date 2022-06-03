resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block}"

  tags = {
    Name = "${ var.app_name }-vpc"
  }
}

#############################
##### Internet Gateway ######
#############################
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name        = "${ var.app_name }-igw"
  }
}

#############################
##### NAT Gateway ######
#############################
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name     = "${ var.app_name }-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "${ var.app_name }-nat"
  }
}

############################
##### Private Subnets ######
############################
resource "aws_subnet" "private_subnet" {
  count             = "${length(var.private_subnets)}"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  tags = {
    Name = "${ var.app_name }-priv-subnet-${count.index+1}"
    Tier = "private"
  }
}

##########################
##### Public Subnets #####
##########################
resource "aws_subnet" "public_subnet" {
  count             = "${length(var.public_subnets)}"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "${element(var.public_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${ var.app_name }-pub-subnet-${count.index+1}"
    Tier = "public"
  }
}

#########################################
##### Private Subnet Routing Table ######
#########################################
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name        = "${ var.app_name }-private-route-table"
  }
}
########################################
##### Public Subnet Routing Table ######
########################################
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name        = "${ var.app_name }-public-route-table"
  }
}

#####################
##### Gateways ######
#####################s
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

##############################
##### Route Associations #####
##############################
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}


##################################
##### Default Security Group #####
##################################
resource "aws_security_group" "default" {
  name        = "${var.app_name}-default-sg"
  description = "Default security group to deny inbound/outbound from the VPC"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.main]


  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    "Name" = "${var.app_name}-default-sg"
  }
}

resource "aws_key_pair" "default" {
  key_name   = "${var.app_name}-keypair"
  public_key = var.ec2_keypair_pub
}
