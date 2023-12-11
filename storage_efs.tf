# EFS CSI Driver
resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-efs-csi-driver"
  addon_version     = "v1.7.1-eksbuild.1"  # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}