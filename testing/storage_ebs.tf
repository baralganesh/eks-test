# ---------------------------------------------------------------
# EBS CSI Driver Addon Installation
# ---------------------------------------------------------------
resource "aws_eks_addon" "ebs_csi" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.23.2-eksbuild.1" # Replace with the actual version you want to install
  resolve_conflicts = "OVERWRITE"
}

# Create Kubernetes service account for EBS CSI driver
resource "kubernetes_service_account" "ebs_csi_sa" {
  metadata {
    name      = "ebs-csi-driver-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver_role.arn
    }
  }
}
