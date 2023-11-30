resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "awsRegion"
    value = "us-east-1" 
  }

  # Additional configurations can be added here.
}


389  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml
  390  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml~
  391  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
