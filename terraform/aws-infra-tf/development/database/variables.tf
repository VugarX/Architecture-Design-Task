variable "region" {
  description = "AWS region where resources will be deployed"
  type = string
  default = "eu-central-1"
}

variable "env" {
  description = "Environment variable"
  default = "dev"
}

variable "project" {
  description = "Project name"
  default = "api-dev"
}

