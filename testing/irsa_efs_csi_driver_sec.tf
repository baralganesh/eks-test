# -------------------------------------------------------------------
# EFS CSI Driver IAM Role
# -------------------------------------------------------------------

module "efs_csi_driver_irsa" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name = "${module.eks.cluster_id}-efs-csi-driver"
  role_description = "IRSA role for EFS CSI Driver"

  attach_efs_csi_policy = true

  allow_external_id = true

  oidc_providers = {
    main = {
      provider_arn  = module.eks.oidc_provider
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}