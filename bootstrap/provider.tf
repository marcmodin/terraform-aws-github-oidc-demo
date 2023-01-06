terraform {
  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  # decide to add s3 backend once resources had been deployed , inception = true
}

provider "aws" {
  region = var.region
}