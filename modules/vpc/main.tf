resource "aws_vpc" "main" {
  cidr_block         = "10.0.0.0/20"
  instance_tenancy   = "default"
  enable_dns_support = true
  # Need this for EFS to work
  # https://stackoverflow.com/questions/71309915/providing-access-to-efs-from-ecs-task
  enable_dns_hostnames = true

  tags = var.tags
}

resource "aws_subnet" "public" {
  for_each = var.public_subnet_numbers

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, each.value)

  tags = merge(
    var.tags,
    {
      component-name = "${var.tags["application"]}-public-subnet"
      az             = each.key
    }
  )

}

#######
# IGW #
#######
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      component-name = "${var.tags["application"]}-igw"
    }
  )

}

###########################
# Route Tables and Routes #
###########################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      component-name = "${var.tags["application"]}-public-rt"
      vpc            = aws_vpc.main.id
    }
  )
}

# Public Route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Public Route to Public Route Table for Public Subnets
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}