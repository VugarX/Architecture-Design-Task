terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = "api-dev-state-file"
    key            = "dev/self-runner/terraform.tfstate"
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
  region = var.region
}

# IAM policy for the runner with necessary permissions
resource "aws_iam_policy" "runner_policy" {
  name        = "github-actions-runner-policy"
  description = "Policy for GitHub Actions runner"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "eks:*",
          "iam:*",
          "s3:*",
          "dynamodb:*",
          "logs:*",
          "sts:AssumeRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "runner_role" {
  name = "github-actions-runner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "runner_policy_attachment" {
  role       = aws_iam_role.runner_role.name
  policy_arn = aws_iam_policy.runner_policy.arn
}

resource "aws_iam_instance_profile" "runner_profile" {
  name = "github-actions-runner-profile"
  role = aws_iam_role.runner_role.name
}

resource "aws_security_group" "runner_sg" {
  name        = "github-runner-sg"
  description = "Allow SSH and Internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to VPC CIDR for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "github-runner-sg"
  }
}

resource "aws_instance" "runner" {
  ami                    = "ami-0a87a69d69fa289be" # Ubuntu 22
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.runner_profile.name
  vpc_security_group_ids = [aws_security_group.runner_sg.id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/install-runner.sh", {
    github_repo  = var.github_repo,
    runner_token = var.runner_token
  }))

  tags = {
    Name = "github-actions-runner"
  }
}