resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "1.23.0"  # Replace with your desired chart version

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

###################################
# https://github.com/kubernetes/autoscaler/releases?page=8
