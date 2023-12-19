# This confguration impacts IAM Roles and IAM Policies used for k8s service accounts

# ---------------------------------------------------------------
# service account for backbase services
# ---------------------------------------------------------------
module "backbase_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name        = "${module.eks.cluster_id}-backbase-sa"
  role_description = "IRSA role for Backbase Services"

  assume_role_condition_test = "StringLike"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*:backbase-sa"]
    }
  }

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
}

# ---------------------------------------------------------------
# service account for cluster_autoscaler
# ---------------------------------------------------------------
module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name        = "${module.eks.cluster_id}-cluster-autoscaler"
  role_description = "IRSA role for cluster autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_id]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}


# ---------------------------------------------------------------
# service account for load_balancer_controller
# ---------------------------------------------------------------
module "load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name        = "${module.eks.cluster_id}-load-balancer-controller"
  role_description = "IRSA role for ALB Controller"
  
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


# ---------------------------------------------------------------
# service account for ebs_csi_driver
# ---------------------------------------------------------------

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.14.0"

  role_name        = "${module.eks.cluster_id}-ebs-csi-driver"
  role_description = "IRSA role for EBS CSI Driver" 

  attach_ebs_csi_policy = true
  
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
      conditions                = {
        StringEquals = {          
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  }
}