terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = "api-dev-state-file"
    key            = "dev/db/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    profile        = "api-dev"
    encrypt        = true
  }
required_providers {
    aws = {
    source = "hashicorp/aws"
    version = "5.83.0"
    }
}

}

provider "aws" {
  region = var.region
}
