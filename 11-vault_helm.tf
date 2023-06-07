resource "helm_release" "vault" {
  name       = "vault"
  namespace  = "vault"
  repository = "hashicorp"
  chart      = "vault"
  version    = "0.24.1"
  set {
    name  = "server.ha.enabled"
    value = "true"
  }
  set {
    name  = "server.ha.raft.enabled"
    value = "true"
  }
#   set {
#     name  = "csi.enabled"
#     value = "true"
#   }
  create_namespace = true

}

