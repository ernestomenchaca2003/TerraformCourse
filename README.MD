# Terraform mini practice

Consists in creating a complete VPC and attach it to an EC2 that includes a web server, this practice can be completed by following the next steps:

## Practice:

1. Create VPC. :heavy_check_mark:
2. Create Internet Gateway. :heavy_check_mark:
3. Create a custom route table. :heavy_check_mark:
4. Create a subnet. :heavy_check_mark:
5. Associate subnet with route table. :heavy_check_mark:
6. Create a security group that allows inbout ports 22, 80, 443. :heavy_check_mark:
7. Create a network interface with an ip in the subnet (created in step 4). :heavy_check_mark:
8. Create an Elastic IP to the network interface (created in step 7). :heavy_check_mark:
9. Create ubuntu server and install/enable Apache2 (Can use Nginx as an alternative). :heavy_check_mark:

### Extras (pending):
10. Implement best practices
11. Use variables
12. Improve code by using outputs (try using 'terraform outputs' after creation)