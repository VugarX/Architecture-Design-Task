terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = "api-dev-state-file"
    key            = "dev/app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    profile        = "api-dev"
    encrypt        = true
  }
}
  

  provider "helm" {
    kubernetes {
      config_path    = "~/.kube/config"
      config_context = "arn:aws:eks:eu-central-1:123456789:cluster/dev-eu-central-1-al2"
    }
  }

  provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:eu-central-1:123456789:cluster/dev-eu-central-1-al2"
  }
