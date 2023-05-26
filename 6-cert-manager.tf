# resource "helm_release" "cert-manager" {
#   name       = "cert-manager"
#   namespace  = "cert-manager"
#   repository = "jetstack"
#   chart      = "cert-manager"
#   version    = "v1.10.1"
#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
#   create_namespace = true

# }

# ------------------------------------------------------
# the helm_release installation has issue with finding the repo, so use command to install it
# helm install cert-manager jetstack/cert-manager \
# --namespace cert-manager \
# --version v1.10.1 \
# --set installCRDs="true"
# ------------------------------------------------------