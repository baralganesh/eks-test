# ---------------------------------------------------------------
# service account for ebs_csi_driver
# ---------------------------------------------------------------
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name        = "${module.eks.cluster_id}-ebs-csi-driver"
  role_description = "IRSA role for EBS CSI Driver" 

  attach_ebs_csi_policy = true

  oidc_provider_arn = module.eks.oidc_provider

  oidc_providers = {
    main = {
      provider_arn               = oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
      conditions                = {
        StringEquals = {
          "${oidc_provider_arn}:aud": "sts.amazonaws.com"
        }
      }
      conditions                = {
        StringEquals = {
          "${oidc_provider_arn}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  }
}