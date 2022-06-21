resource "aws_vpc" "main" {
  cidr_block = var.CIDR_BLOCK

  tags = {
    Name = "${var.APP_NAME}-vpc"
  }
}

#############################
##### Internet Gateway ######
#############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.APP_NAME}-igw"
  }
}

#############################
##### NAT Gateway ######
#############################
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.APP_NAME}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.APP_NAME}-nat"
  }
}

############################
##### Private Subnets ######
############################
resource "aws_subnet" "private_subnet" {
  count             = length(var.PRIVATE_SUBNETS)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.PRIVATE_SUBNETS, count.index)
  availability_zone = element(var.AVAILABILITY_ZONES, count.index)
  tags = {
    Name = "${var.APP_NAME}-priv-subnet-${count.index + 1}"
  }
}

##########################
##### Public Subnets #####
##########################
resource "aws_subnet" "public_subnet" {
  count                   = length(var.PUBLIC_SUBNETS)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.PUBLIC_SUBNETS, count.index)
  availability_zone       = element(var.AVAILABILITY_ZONES, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.APP_NAME}-pub-subnet-${count.index + 1}"
  }
}

#########################################
##### Private Subnet Routing Table ######
#########################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.APP_NAME}-private-route-table"
  }
}
########################################
##### Public Subnet Routing Table ######
########################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.APP_NAME}-public-route-table"
  }
}

###################
##### Routes ######
###################
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_to_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

##############################
##### Route Associations #####
## Associate RTs to Subnets ##
##############################
resource "aws_route_table_association" "public" {
  count          = length(var.PUBLIC_SUBNETS)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.PRIVATE_SUBNETS)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

##################################
##### Default Security Group #####
##################################
resource "aws_default_security_group" "default" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]


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
    "Name" = "${var.APP_NAME}-default-sg"
  }
}


resource "aws_security_group" "admin" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    self        = "true"
    cidr_blocks = [var.ADMIN_IP_ADDRESSES]
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "TCP"
    self        = "true"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
  }

  tags = {
    "Name" = "${var.APP_NAME}-admin-sg"
  }
}
