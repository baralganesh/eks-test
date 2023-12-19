# -------------------------------------------------------------------
# EFS CSI Driver Addon Integration
# -------------------------------------------------------------------

resource "aws_eks_addon" "efs_csi" {
  cluster_name   = module.eks.cluster_id
  addon_name     = "aws-efs-csi-driver"
  addon_version  = "v1.7-eksbuild.1" # Replace with the actual version you want to install
  resolve_conflicts = "OVERWRITE"
  service_account_role_arn = "arn:aws:iam::${local.account_id}:role/${module.eks.cluster_id}-efs-csi-driver"
}
