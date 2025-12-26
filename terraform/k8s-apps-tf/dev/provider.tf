provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:eu-central-1:510543735205:cluster/development-eu-central-1-al2"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:eu-central-1:510543735205:cluster/development-eu-central-1-al2"
}
