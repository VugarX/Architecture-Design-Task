data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket         = "api-dev-state-file"
    key            = "dev/vpc/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    profile        = "api-dev"
    encrypt        = true
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

module "eks_al2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.env}-${var.region}-al2"
  cluster_version = "1.31"
  cluster_endpoint_public_access  = true

  authentication_mode = "API"
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  
  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

    vpc_id     = "vpc-028acef73811bdd71"
    subnet_ids = [
      "subnet-0370348ec1d8eaf6f",
      "subnet-0b74e84311e9055e7"
    ]
    
  eks_managed_node_groups = {
    dev-k8s-ng = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size = 2
      max_size = 5
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2

    }

  }

}




module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks_al2.cluster_name
  cluster_endpoint  = module.eks_al2.cluster_endpoint
  cluster_version   = module.eks_al2.cluster_version
  oidc_provider_arn = module.eks_al2.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      resolve_conflicts = "NONE"
      service_account_role_arn =  module.ebs_csi_driver_irsa.iam_role_arn
    }    
  }

  enable_cluster_autoscaler     = true
  enable_aws_cloudwatch_metrics = true

  tags = {
    Environment = var.env
    Terraform   = true 
  }
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${var.env}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks_al2.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Environment = var.env
    Terraform   = true 
  }
}