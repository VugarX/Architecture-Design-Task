variable "region" {
  default = "eu-central-1"
}

variable "vpc_id" {
  default = "vpc-123456789"
}
variable "subnet_id" {
  default = "subnet-123456789"
}
variable "instance_type" {
  default = "t3.medium"
}

variable "github_repo" {
  description = "Format: org/repo"
}

variable "runner_token" {
  description = "GitHub Actions registration token"
  sensitive   = true
}
