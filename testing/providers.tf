terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.10"
    }
  }
  
  # export TF_CLI_CONFIG_FILE="$HOME/.terraform.d/.terraformrc-leap-dev"
  cloud {
    organization = "gbaral-dev"

    workspaces {
      name = "BankUnited-Community-DigitalBanking-Leap-DB-dev-poc" # CREATE WORKSPACE FIRST
    }
  }

}

# AWS credentials used is defined in TFE Env Variables
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::031342435657:role/bkutfeassumeadmin"
  }
}

  provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.eks.token
}
