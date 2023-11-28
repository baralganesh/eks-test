################################################################################
# Create AWS EKS Cluster using terraform-aws-eks module
# Configuration files:
# - main.tf       # this
# - locals.tf     # env specific values
# - irsa.tf       # IAM roles for service accounts
# - providers.tf
# - outputs.tf
################################################################################

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.20.5"

  # cluster config
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id = local.vpc_id
  # private subnets
  subnet_ids = local.subnet_ids

  cluster_endpoint_public_access          = true
  cluster_endpoint_private_access         = true
  cluster_enabled_log_types               = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days  = 7
  # cluster_security_group_additional_rules = local.cluster_sg_rules
  
  add_ons = {
    ebs_csi_driver = {
      enabled = true
      version = "1.25.0-eksbuild.1"  # Specify the desired version here
    },
    efs_csi_driver = {
      enabled = true
      version = "v1.7.1-eksbuild.1"  # Specify the desired version here
    }
    # You can add more add-ons if needed
  }

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  tags = local.tags_cluster_all
  
  ############################################
  # aws-auth configmap
  ############################################
  
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${local.account_id}:role/bkutfeassumeadmin"
      username = "bkutfeassumeadmin"
      groups   = ["system:masters"]
    },
  ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/ganesh.baral"
      username = "ganesh.baral"
      groups   = ["system:masters"]
    },
  ]

  
  ############################################
  # Self-managed nodes
  ############################################

  self_managed_node_groups = {
    node_group_sv123 = {
      name          = "${local.cluster_name}-snode-v123"
      ami_id        = "ami-063c96f0f567e495e"
      instance_type = local.instance_type
      min_size      = 2
      desired_size  = 2
      max_size      = 4
      key_name      = local.key_name
      tags          = local.tags_nodegroup
      propagate_at_launch = true

      block_device_mappings        = local.node_block_device
      iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
      security_group_rules         = local.node_sg_rules
      
      attach_cluster_primary_security_group = true
      
      # Enable containerd, ssm
      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      EOT
    }
  }

}

################################################################################
# Create KMS key for secret envelope encryption
################################################################################
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key for ${local.cluster_name}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = {
    Name = "${local.cluster_name}-key"
    Note = "Created by terraform for EKS cluster ${local.cluster_name}"
  }
}

################################################################################
# Notes
################################################################################
# AMI for EKS Linux Nodes 
# https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
# https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html
#
# us-east-1 x86
# 1.23 = ami-0f6ad55c14fec6386
