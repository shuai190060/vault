
# VPC
resource "aws_vpc" "vpc_vault" {
  cidr_block = var.vpc_cidr

  tags = var.tags

}

# internet gateway
resource "aws_internet_gateway" "igw_vault" {
  vpc_id = aws_vpc.vpc_vault.id

  tags = var.tags
}


# public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_cidrblock)
  vpc_id                  = aws_vpc.vpc_vault.id
  cidr_block              = var.public_cidrblock[count.index]
  availability_zone       = var.av_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    "Name"                        = "public-${var.av_zone[0]}"
    "kubernetes.io/role/elb"      = "1"     # public elb
    "kubernetes.io/cluster/vault_cluster" = "owned" # under cluster demo
  }

}

# private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidrblock)
  vpc_id            = aws_vpc.vpc_vault.id
  cidr_block        = var.private_cidrblock[count.index]
  availability_zone = var.av_zone[count.index]

  tags = {
    "Name"                            = "private-${var.av_zone[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"     # private elb
    "kubernetes.io/cluster/vault_cluster"     = "owned" # under cluster vault
    #   "karpenter.sh/discovery" = "true"    # incase i want to auto scale node with karpenter

  }
}


# elastic ip for the public subnets
resource "aws_eip" "eip" {
  vpc   = true
  count = length(var.public_cidrblock)
  tags = {
    "Name" = "EIP-${count.index + 1}"
  }
}

# nat gateway for private subnets
resource "aws_nat_gateway" "nat" {
  count         = length(var.av_zone)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  depends_on = [aws_internet_gateway.igw_vault]

  tags = {
    "Name" = "Nat-${count.index + 1}"
  }

}

# route tables for private and public
resource "aws_route_table" "private_route" {
  count  = length(var.av_zone)
  vpc_id = aws_vpc.vpc_vault.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    "Name" = "private"
  }

}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc_vault.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vault.id
  }
  tags = {
    "Name" = "public"
  }
}

# routing private
resource "aws_route_table_association" "private" {
  count          = length(var.private_cidrblock)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)

}

# routing public
resource "aws_route_table_association" "public" {
  count          = length(var.public_cidrblock)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route.id
}

