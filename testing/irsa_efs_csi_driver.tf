# ---------------------------------------------------------------
# service account for efs_csi_driver
# ---------------------------------------------------------------

module "efs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name        = "${module.eks.cluster_id}-efs-csi-driver"
  role_description = "IRSA role for EFS CSI Driver"

  # Assuming there is a predefined policy for EFS CSI
  attach_efs_csi_policy = true
  
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
      conditions                = {
        StringEquals = {          
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }
  }
}
