################################################################################
# Environment/Cluster specific values
################################################################################

locals {
  cluster_name    = "tfeks-leap-poc"
  cluster_version = "1.23"

  # vpc private subnets
  vpc_id     = "vpc-fc30e286"
  account_id = "031342435657"
  subnet_ids = ["subnet-990e88fe","subnet-11109d3f"]
  # cidr_blocks
  # cluster_endpoint_private_access_cidrs = ["10.17.0.0/16","172.16.0.0/16","172.17.0.0/16","192.168.0.0/16","10.59.16.190/32"]

  # tags_cluster_all is for all resources created
  tags_cluster_all = {
    ApplicationName     = "Backbase"
    Environment         = "Development"
    owner               = "ganesh.baral"
    Name                = "LEAP Testing" 
  }

  # Cluster additional SG rules
  cluster_sg_rules = {
    ingress_vpn = {
      description = "BKU VPN Access"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["192.168.0.0/16","172.16.0.0/16","172.17.0.0/16"]
      type        = "ingress"
    }
    ingress_tools = {
      description = "Tools Access"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["10.17.0.0/16"]
      type        = "ingress"
    }
    ingress_brickell = {
      description = "Brickell Office"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["10.59.0.0/16"]
      type        = "ingress"
    }
  }
  #-------------------------------------------------------------
  # Node Group values
  # Other values set in main.tf (node name, asg size, ami id)
  #-------------------------------------------------------------

  instance_type = "t2.micro"
  key_name      = "ganeshbaral-sandbox" 
  
  node_block_device = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size = 100 #root ebs volume size in GB
        volume_type = "gp3"
        encrypted   = true
      }
    }
  }

  # Node additional tags
  tags_nodegroup = {
    "k8s.io/cluster-autoscaler/enabled"               = "true"
    "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
    "owner"                                           = "ganesh.baral"
  }

  # Node additional SG rules
  node_sg_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_cluster_to_nodes = {
      description                   = "Cluster to Node communication"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

}
