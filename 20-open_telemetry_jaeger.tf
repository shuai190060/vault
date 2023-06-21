# jaeger default helm, with cassandra backend
resource "helm_release" "jaeger" {
  name       = "jaeger"
  namespace  = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaegertracing"
  version    = "0.71.4"

  create_namespace = true

}

# intall telemetry operator helm chart
resource "helm_release" "opentelemetry_operator" {
  name       = "opentelemetry-operator"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-operator"
  namespace  = "opentelemetry-operator-system"
  version    = "0.32.0"

  create_namespace = true
}