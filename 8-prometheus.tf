# resource "helm_release" "prometheus-stack" {
#   name = "prometheus-stack"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart = "kube-prometheus-stack"
#   version = "45.31.0"
#   values = [ "${file("prometheus_values.yaml")}" ]

#   namespace = "monitoring"
#   create_namespace = true

# }