# resource "helm_release" "nginx_ingress_controller" {
#   name = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart = "ingress-nginx"
#   version = "4.4.2"
#   values = [ "${file("ingress-nginx-values.yaml")}" ]

#   namespace = "ingress"
#   create_namespace = true

# }