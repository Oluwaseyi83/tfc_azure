terraform {
  cloud {
    organization = "OYADEYI-TECH-SERVICES"

    workspaces {
      name = "aws_workspace"
    }
  }


  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.55.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
  #profile = "default"
}