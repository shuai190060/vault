resource "helm_release" "prometheus-stack" {
  name = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = "45.31.0"
  values = [ "${file("./monitoring/values/prometheus_values.yaml")}" ]

  namespace = "monitoring"
  create_namespace = true

}


# resource "helm_release" "cadvisor" {
#   name      = "cadvisor"
#   repository = "https://ckotzbauer.github.io/helm-charts"
#   chart     = "cadvisor"
#   version   = "2.2.4"
#   namespace = "monitoring"

#   values = <<EOF
#   serviceMonitor:
#     additionalLabels: 
#       prometheus: watched
#   EOF
# }