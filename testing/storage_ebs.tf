# ---------------------------------------------------------------
# EBS CSI Driver Addon Installation
# ---------------------------------------------------------------
resource "aws_eks_addon" "ebs_csi" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "ebs-csi-driver"
  addon_version     = "<desired_version>" # Specify the version you want to install  
  resolve_conflicts = "OVERWRITE"
  service_account   = aws_iam_role.ebs_csi_driver_role.arn
}