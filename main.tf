#? 1. VPC Creation
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.4.0.0/16"

  tags = {
    Name        = "terraform-development-vpc"
    Environment = "development"
    Resource    = "vpc"
    Description = "Resource created by terraform"
  }
}

#? 2. Create Internet Gateway

resource "aws_internet_gateway" "tf-internet-gateway" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name        = "terraform-development-igw"
    Environment = "development"
    Resource    = "internet-gateway"
    Description = "Internet Gateway Created by terraform and attached it to VPC-${aws_vpc.tf-vpc.id}"
  }
}

#? 3. Create Route table 1

resource "aws_egress_only_internet_gateway" "tf-egress-internet-gateway" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "terraform-egress-internet-gateway"
    Environment = "development"
    Resource = "egress-internet-gateway"
    Description = "Egress IGW created by terraform, associated with ${aws_vpc.tf-vpc.id}"
  }
}

resource "aws_route_table" "tf-route-table-1" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-internet-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.tf-egress-internet-gateway.id
  }


  tags = {
    Name        = "terraform-public-route-table-1"
    Environment = "development"
    Resource    = "route-table"
    Description = "Route table created by terraform and attachet it to subnet-${aws_subnet.tf-subnet-1.id}"
  }

}

#? 3. Create route table 2

resource "aws_route_table" "tf-route-table-2" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-internet-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.tf-egress-internet-gateway.id
  }

  tags = {
    Name        = "terraform-public-route-table-2"
    Environment = "development"
    Resource    = "route-table"
    Description = "Route table created by terraform and attachet it to subnet-${aws_subnet.tf-subnet-2.id}"
  }

}

#* 4. Subnet
#? Here we're referencing both subnets with "tf-vpc" resource 
resource "aws_subnet" "tf-subnet-1" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "10.4.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Environment = "development"
    Name        = "terraform-public-subnet-1"
    Resource    = "subnet"
    Description = "Subnet created by terrafom VPC-${aws_vpc.tf-vpc.id}"
  }
}

resource "aws_subnet" "tf-subnet-2" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "10.4.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Environment = "development"
    Name        = "terraform-public-subnet-2"
    Resource    = "subnet"
    Description = "Subnet created by terrafom VPC-${aws_vpc.tf-vpc.id}"
  }
}

#? 5. Route table subnets association

resource "aws_route_table_association" "tf-route-association-1" {

  subnet_id      = aws_subnet.tf-subnet-1.id
  route_table_id = aws_route_table.tf-route-table-1.id
}

resource "aws_route_table_association" "tf-route-association-2" {

  subnet_id      = aws_subnet.tf-subnet-2.id
  route_table_id = aws_route_table.tf-route-table-2.id
}

# resource "aws_instance" "ec2_terraform" {
#   ami           = "ami-0261755bbcb8c4a84" #Ubuntu 20.04 LTS 2023
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Ubuntu instance - Created with terraform"
#   }

# }

