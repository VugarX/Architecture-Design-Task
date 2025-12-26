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
