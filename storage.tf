# EBS CSI Driver
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.23.2-eksbuild.1"  # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
  # service_account_role_arn = "arn:aws:iam::031342435657:role/AmazonEKS_EBS_CSI_DriverRole_tfeks_test"  # Replace with required IAM role ARN
}

# EFS CSI Driver
resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-efs-csi-driver"
  addon_version     = "v1.7.1-eksbuild.1"  # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}