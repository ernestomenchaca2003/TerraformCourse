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
resource "aws_route_table" "tf-route-table-1" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-internet-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.tf-internet-gateway.id
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
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.tf-internet-gateway.id
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

#? 6. Create a security group that allows inbout ports 22, 80, 443.

resource "aws_security_group" "tf-security-group" {
  name        = "terraform-security-group"
  description = "Secutity group for EC2 created by terraform"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "terraform-security-group"
    Resource    = "security-group"
    Environment = "development"
    Description = "Security group for EC2 instance created by terraform"
  }
}

#? 7. Create a network interface with an ip in the subnet (created in step 4).

resource "aws_network_interface" "tf-eni-1" {
  subnet_id       = aws_subnet.tf-subnet-1.id
  private_ips     = ["10.4.1.50"]
  security_groups = [aws_security_group.tf-security-group.id]

}

resource "aws_network_interface" "tf-eni-2" {
  subnet_id       = aws_subnet.tf-subnet-2.id
  private_ips     = ["10.4.2.51"]
  security_groups = [aws_security_group.tf-security-group.id]

}

#? 8. Create an Elastic IP to the network interface (created in step 7).

resource "aws_eip" "tf-eip-1" {

  domain                    = "vpc"
  network_interface         = aws_network_interface.tf-eni-1.id
  associate_with_private_ip = "10.4.1.50"

  depends_on = [aws_internet_gateway.tf-internet-gateway]

  tags = {
    Name        = "terraform-elastic-ip-for-ec2"
    Environment = "development"
    Resource    = "elastic-ip"
    Description = "Elastic IP used for EC2 Instance and created by terraform"
  }
}

# resource "aws_eip" "tf-eip-2" {

#   vpc = true
#   network_interface = aws_network_interface.tf-eni-2.id
#  depends_on = aws_internet_gateway.tf-internet-gateway
#  
# }
#? 9. Create ubuntu server and install/enable Apache2 (Can use Nginx as an alternative).
resource "aws_instance" "ec2_terraform" {
  ami               = "ami-0261755bbcb8c4a84" #Ubuntu 20.04 LTS 2023
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "terraform-main-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.tf-eni-1.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo First web server using Terraform and Apache2 > /var/www/html/index.html'
                EOF 

  tags = {
    Name = "Ubuntu instance - Created with terraform"
  }

}

