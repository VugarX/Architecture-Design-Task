resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.9.1"
  values = [file("values/values-argocd.yaml")]
}

resource "helm_release" "external-secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets-op"
  create_namespace = true
  version          = "v0.16.1"
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Install traefik helm chart
resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = "kube-system"
  chart      = "traefik/traefik"
  version    = "35.2.0"

  values = [
    file("values/values-traefik.yaml")
  ]
}
