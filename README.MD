# Terraform mini practice

Consists in creating a complete VPC and attach it to an EC2 that includes a web server, this practice can be completed by following the next steps:

## Practice:

1. Create VPC
2. Create Internet Gateway
3. Create a custom route table
4. Create a subnet
5. Associate subnet with route table
6. Create a security group that allows inbout ports 22, 80, 443
7. Create a network interface with an ip in the subnet (created in step 4)
8. Create an Elastic IP to the network interface (created in step 7)
9. Create ubuntu server and install/enable Apache2 (Can use Nginx as an alternative)