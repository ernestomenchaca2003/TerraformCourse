terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAT2CQ4JDN65IYHJ3M"
  secret_key = "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"
}