resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.9.2"  # Specify the version you want to use

  set {
    name  = "installCRDs"
    value = "true"
  }

  # Include additional configuration parameters as needed
}


#########################################
# https://cert-manager.io/docs/releases/
# https://cert-manager.io/docs/releases/release-notes/release-notes-1.9/

# check versions:
# helm repo add autoscaler https://kubernetes.github.io/autoscaler
# helm search repo autoscaler/cluster-autoscaler --versions
