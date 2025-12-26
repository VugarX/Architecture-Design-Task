terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = "api-dev-state-file"
    key            = "dev/eks-cluster1/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    profile        = "api-dev"
    encrypt        = true
  }
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.95"  # This satisfies >= 5.95.0
  }

  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = "~> 2.31.0"
  }

  helm = {
    source  = "hashicorp/helm"
    version = "~> 2.14.0"
  }    
}

}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = module.eks_al2.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_al2.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", 
        "get-token", 
        "--cluster-name", 
        module.eks_al2.cluster_name,
        "--region",
        var.region,
        "--profile",
        "api-dev"  
      ]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks_al2.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_al2.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", 
      "get-token", 
      "--cluster-name", 
      module.eks_al2.cluster_name,
      "--region",
      var.region,
      "--profile",
      "api-dev"  
    ]
  }
}