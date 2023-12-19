# ---------------------------------------------------------------
# CNI
# ---------------------------------------------------------------
resource "aws_eks_addon" "cni" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "vpc-cni"
  addon_version     = "v1.10.4-eksbuild.1" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# ---------------------------------------------------------------
# coredns
# ---------------------------------------------------------------
resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  addon_version     = "v1.8.7-eksbuild.2" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# ---------------------------------------------------------------
# kube-proxy
# ---------------------------------------------------------------
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "kube-proxy"
  addon_version     = "v1.23.7-eksbuild.1" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# ---------------------------------------------------------------
# EBS CSI Driver Addon Installation
# ---------------------------------------------------------------
resource "aws_eks_addon" "ebs_csi" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.23.2-eksbuild.1" # Replace with the actual version you want to install
  resolve_conflicts = "OVERWRITE"
  service_account_role_arn = "arn:aws:iam::${local.account_id}:role/${module.eks.cluster_id}-ebs-csi-driver"
}