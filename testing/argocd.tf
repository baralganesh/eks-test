resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
  version    = "2.7.14" 

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Additional settings can be configured here
}


######## * NOTES * ###########

# https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/
# https://github.com/argoproj/argo-cd/releases
# https://artifacthub.io/packages/helm/argo/argo-cd
