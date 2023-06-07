resource "helm_release" "argocd-image-updater" {
  name = "argocd-image-updater"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  namespace        = "argocd"
  create_namespace = true
  version          = "0.9.1"

  values = ["${file("./argocd/values/argocd_image_updater_values.yaml")}"]

}