#-------------------------------------------------------------------------
# Istio base installation with helm
#-------------------------------------------------------------------------

resource "helm_release" "istio-base" {
  name = "istio-base"
  repository = "istio"
  chart      = "base"
  version    = "1.17.2"
  namespace = "istio-system"
  create_namespace = true

}

#-------------------------------------------------------------------------
# Istiod installation with helm
#-------------------------------------------------------------------------

resource "helm_release" "istiod" {
  name = "istiod"
  repository = "istio"
  chart      = "istiod"
  version    = "1.17.2"
  namespace = "istio-system"
  create_namespace = true

  set {
    name = "pilot.resources.requests.memory"
    value = "1024Mi"
  }

  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }

  set {
    name  = "meshConfig.ingressService"
    value = "istio-ingress-gateway"
  }

  set {
    name  = "meshConfig.ingressSelector"
    value = "ingress-gateway"
  }

  set {
    name  = "meshConfig.ingressClass"
    value = "istio"
  }

  depends_on = [ helm_release.istio-base ]
}



#-------------------------------------------------------------------------
# Kiali-server or kiali-operator installation with helm
#-------------------------------------------------------------------------

resource "helm_release" "kiali-server" {
  name = "kiali"
  repository = "kiali"
  chart      = "kiali-server"
  version    = "1.69.0"
  namespace = "istio-system"
#   create_namespace = true

  set {
    name = "istio_namespace"
    value = "istio-system"
  }

  set {
    name = "auth.strategy"
    value = "token"
  }

  depends_on = [ helm_release.istio-base ]
}
# #-------------------------------------------------------------------------
# # kiali operator, duplicate with the kiali server
# #-------------------------------------------------------------------------


# resource "helm_release" "kiali-operator" {
#   name = "kiali-operator"
#   repository = "kiali"
#   chart      = "kiali-operator"
#   version    = "1.69.0"
#   namespace = "istio-system"
# #   create_namespace = true

#   set {
#     name = "cr.create"
#     value = "true"
#   }

#   set {
#     name = "cr.namespace"
#     value = "kiali-operator"
#   }

#   depends_on = [ helm_release.istio-base ]
# }

# #-------------------------------------------------------------------------
# # provision prometheus for kiali
# #-------------------------------------------------------------------------

# resource "helm_release" "prometheus-stack" {
#   name = "prometheus-stack"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart = "kube-prometheus-stack"
#   version = "45.31.0"
#   values = [ "${file("prometheus_values.yaml")}" ]

#   namespace = "istio-system"

# }


resource "helm_release" "istio_ingress_gateway" {
  name = "istio-ingress-gateway"
  repository = "istio"
  chart      = "gateway"
  version    = "1.17.2"
  namespace = "istio-system"
  create_namespace = true

#   values = ["${file("./istio/0-values/2-gateway.yaml")}"]

  depends_on = [ helm_release.istio-base, helm_release.istiod]
}
