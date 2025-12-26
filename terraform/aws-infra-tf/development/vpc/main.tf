terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = "api-dev-state-file"
    key            = "dev/vpc/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    profile        = "api-dev"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source = "git::https://github.com/infra-modules-terraform.git//aws_network?ref=main"

  environment   = "dev"
  project_name  = "api-dev"
  cidr_block    = "10.1.0.0/16"
  #vpc_id        = null # or omit this if your module handles optionality
  region        = "eu-central-1"

  public_subnets   = ["10.1.4.0/24", "10.1.5.0/24"]
  private_subnets  = ["10.1.0.0/24", "10.1.1.0/24"]
  database_subnets = ["10.1.8.0/24", "10.1.9.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
