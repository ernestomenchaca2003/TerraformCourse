#? VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.4.0.0/16"

  tags = {
    Name = "development-vpc"
    Resource = "vpc"
    Description ="Resource created by terraform"
  }
}

#* Subnet
#? Here we're referencing both subnets with "tf-vpc" resource 
resource "aws_subnet" "tf-subnet-1" {
  vpc_id = aws_vpc.tf-vpc.id
  cidr_block = "10.4.1.0/24"
}

resource "aws_subnet" "tf-subnet-2" {
  vpc_id = aws_vpc.tf-vpc.id
  cidr_block = "10.4.2.0/24"
}


# resource "aws_instance" "ec2_terraform" {
#   ami           = "ami-0261755bbcb8c4a84" #Ubuntu 20.04 LTS 2023
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Ubuntu instance - Created with terraform"
#   }

# }

