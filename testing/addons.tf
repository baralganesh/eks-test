# CNI
resource "aws_eks_addon" "cni" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "vpc-cni"
  addon_version     = "v1.10.4-eksbuild.1" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# coredns
resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  addon_version     = "v1.8.7-eksbuild.2" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "kube-proxy"
  addon_version     = "v1.23.7-eksbuild.1" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}