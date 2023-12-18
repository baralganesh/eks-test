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

