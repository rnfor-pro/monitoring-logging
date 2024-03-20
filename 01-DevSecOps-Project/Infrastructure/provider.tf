provider "aws" {
  region = var.AWS_REGION
}

terraform {
  required_providers {
    aws = {
      version = "~>4.0"
      source  = "hashicorp/aws"
    }
  }
}