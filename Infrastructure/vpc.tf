resource "aws_vpc" "COURSE_VPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(
    {
      "Name" = "${local.name_prefix}-VPC"
    },
    local.default_tags,
  )
}

resource "aws_internet_gateway" "COURSE_IGW" {
  vpc_id = aws_vpc.COURSE_VPC.id
  tags = merge(
    {
      "Name" = "${local.name_prefix}-IGW"
    },
    local.default_tags,
  )
}

resource "aws_subnet" "COURSE_PUBLIC_SUBNET" {
  map_public_ip_on_launch = true
  availability_zone       = element(var.az_names, 0)
  vpc_id                  = aws_vpc.COURSE_VPC.id
  cidr_block              = element(var.subnet_cidr_blocks, 0)
  tags = merge(
    {
      "Name" = "${local.name_prefix}-SUBNET-AZ-A"
    },
    local.default_tags,
  )
}

resource "aws_subnet" "COURSE_PRIVATE_SUBNET" {
  map_public_ip_on_launch = false
  availability_zone       = element(var.az_names, 1)
  vpc_id                  = aws_vpc.COURSE_VPC.id
  cidr_block              = element(var.subnet_cidr_blocks, 1)
  tags = merge(
    {
      "Name" = "${local.name_prefix}-SUBNET-AZ-B"
    },
    local.default_tags,
  )
}

resource "aws_eip" "APP_EIP" {
}

resource "aws_nat_gateway" "COURSE_NAT" {
  subnet_id     = aws_subnet.COURSE_PUBLIC_SUBNET.id
  allocation_id = aws_eip.APP_EIP.id
  tags = merge(
    {
      "Name" = "${local.name_prefix}-NGW"
    },
    local.default_tags,
  )
}

resource "aws_route_table" "COURSE_PUBLIC_ROUTE" {
  vpc_id = aws_vpc.COURSE_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.COURSE_IGW.id
  }

  tags = merge(
    {
      "Name" = "${local.name_prefix}-PUBLIC-RT"
    },
    local.default_tags,
  )
}

resource "aws_route_table" "COURSE_PRIVATE_ROUTE" {
  vpc_id = aws_vpc.COURSE_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.COURSE_NAT.id
  }

  tags = merge(
    {
      "Name" = "${local.name_prefix}-PRIVATE-RT"
    },
    local.default_tags,
  )
}

resource "aws_vpc_endpoint" "COURSE_S3_ENDPOINT" {
  vpc_id          = aws_vpc.COURSE_VPC.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.COURSE_PUBLIC_ROUTE.id, aws_route_table.COURSE_PRIVATE_ROUTE.id]
}

resource "aws_route_table_association" "PUBLIC_ASSO" {
  route_table_id = aws_route_table.COURSE_PUBLIC_ROUTE.id
  subnet_id      = aws_subnet.COURSE_PUBLIC_SUBNET.id
}

resource "aws_route_table_association" "PRIVATE_ASSO" {
  route_table_id = aws_route_table.COURSE_PRIVATE_ROUTE.id
  subnet_id      = aws_subnet.COURSE_PRIVATE_SUBNET.id
}

resource "aws_network_acl" "COURSE_NACL" {
  vpc_id     = aws_vpc.COURSE_VPC.id
  subnet_ids = [aws_subnet.COURSE_PRIVATE_SUBNET.id, aws_subnet.COURSE_PUBLIC_SUBNET.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 23
    to_port    = 23
  }

  ingress {
    protocol   = "-1"
    rule_no    = 32766
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 23
    to_port    = 23
  }

  egress {
    protocol   = "-1"
    rule_no    = 32766
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    {
      "Name" = "${local.name_prefix}-NACL"
    },
    local.default_tags,
  )
}

resource "aws_security_group" "APP_ALB_SG" {
  vpc_id = aws_vpc.COURSE_VPC.id
  name   = "${local.name_prefix}-ALB-SG"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [aws_security_group.APP_SG.id]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [aws_security_group.APP_SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = "${local.name_prefix}-SG"
    },
    local.default_tags,
  )
}

resource "aws_security_group" "APP_SG" {
  vpc_id = aws_vpc.COURSE_VPC.id
  name   = "${local.name_prefix}-SG"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [aws_vpc.COURSE_VPC.cidr_block]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [aws_vpc.COURSE_VPC.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      "Name" = "${local.name_prefix}-SG"
    },
    local.default_tags,
  )
}