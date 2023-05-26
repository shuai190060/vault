resource "helm_release" "sealed-secrets" {
  name       = "sealed-secrets"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "sealed-secrets"
  version    = "1.4.2"


}
