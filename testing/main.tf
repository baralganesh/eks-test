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

# EBS CSI Driver
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.25.0-eksbuild.1"  # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# EFS CSI Driver
resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-efs-csi-driver"
  addon_version     = "v1.7.1-eksbuild.1"  # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# CNI
resource "aws_eks_addon" "cni" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "vpc-cni"
  addon_version     = "v1.10.4-eksbuild.1" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# coredns
resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  addon_version     = "v1.8.7-eksbuild.2" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "kube-proxy"
  addon_version     = "v1.23.7-eksbuild.1" # Ensure this version is compatible
  resolve_conflicts = "OVERWRITE"
}

# Metrics server
resource "kubernetes_manifest" "serviceaccount_kube_system_metrics_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server"
      "namespace" = "kube-system"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_system_aggregated_metrics_reader" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
        "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
        "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
        "rbac.authorization.k8s.io/aggregate-to-view" = "true"
      }
      "name" = "system:aggregated-metrics-reader"
    }
    "rules" = [
      {
        "apiGroups" = [
          "metrics.k8s.io",
        ]
        "resources" = [
          "pods",
          "nodes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_system_metrics_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "system:metrics-server"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes/metrics",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "nodes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_kube_system_metrics_server_auth_reader" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server-auth-reader"
      "namespace" = "kube-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "extension-apiserver-authentication-reader"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "metrics-server"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_metrics_server_system_auth_delegator" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server:system:auth-delegator"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "system:auth-delegator"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "metrics-server"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_system_metrics_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "system:metrics-server"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "system:metrics-server"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "metrics-server"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "service_kube_system_metrics_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server"
      "namespace" = "kube-system"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "https"
          "port" = 443
          "protocol" = "TCP"
          "targetPort" = "https"
        },
      ]
      "selector" = {
        "k8s-app" = "metrics-server"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_kube_system_metrics_server" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "metrics-server"
      "namespace" = "kube-system"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "k8s-app" = "metrics-server"
        }
      }
      "strategy" = {
        "rollingUpdate" = {
          "maxUnavailable" = 0
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "k8s-app" = "metrics-server"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--cert-dir=/tmp",
                "--secure-port=4443",
                "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
                "--kubelet-use-node-status-port",
                "--metric-resolution=15s",
              ]
              "image" = "registry.k8s.io/metrics-server/metrics-server:v0.6.4"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/livez"
                  "port" = "https"
                  "scheme" = "HTTPS"
                }
                "periodSeconds" = 10
              }
              "name" = "metrics-server"
              "ports" = [
                {
                  "containerPort" = 4443
                  "name" = "https"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/readyz"
                  "port" = "https"
                  "scheme" = "HTTPS"
                }
                "initialDelaySeconds" = 20
                "periodSeconds" = 10
              }
              "resources" = {
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "200Mi"
                }
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 1000
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-dir"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "priorityClassName" = "system-cluster-critical"
          "serviceAccountName" = "metrics-server"
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "tmp-dir"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "apiservice_v1beta1_metrics_k8s_io" {
  manifest = {
    "apiVersion" = "apiregistration.k8s.io/v1"
    "kind" = "APIService"
    "metadata" = {
      "labels" = {
        "k8s-app" = "metrics-server"
      }
      "name" = "v1beta1.metrics.k8s.io"
    }
    "spec" = {
      "group" = "metrics.k8s.io"
      "groupPriorityMinimum" = 100
      "insecureSkipTLSVerify" = true
      "service" = {
        "name" = "metrics-server"
        "namespace" = "kube-system"
      }
      "version" = "v1beta1"
      "versionPriority" = 100
    }
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
