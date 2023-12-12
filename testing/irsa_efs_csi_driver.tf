# ---------------------------------------------------------------
# service account for efs_csi_driver
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# IAM Role for EFS CSI Driver
# ---------------------------------------------------------------
resource "aws_iam_role" "efs_csi_driver_role" {
  name = "${module.eks.cluster_id}-efs-csi-driver"

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
            "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver-attach" {
  role       = aws_iam_role.efs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}
