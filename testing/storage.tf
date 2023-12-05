# EBS CSI Driver
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.23.2-eksbuild.1"  # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# EFS CSI Driver
resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-efs-csi-driver"
  addon_version     = "v1.7.1-eksbuild.1"  # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}