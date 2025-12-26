resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "external_secrets_namespace" {
  metadata {
    name = "external-secrets-operator"
  }
}