# ---------------------------------------------------------------
# service account for ebs_csi_driver
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# IAM Role for EBS CSI Driver
# ---------------------------------------------------------------
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${module.eks.cluster_id}-ebs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/${module.eks.oidc_provider}"
        },
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud": "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver-attach" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
