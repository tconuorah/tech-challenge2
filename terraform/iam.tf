# EKS cluster IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eksClusterRole"

  # Trust policy (cluster-trust-policy.json equivalent)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "eksClusterRole"
  }
}

###############################################################
# Attach required AWS managed IAM policies
###############################################################

# Core policy required for EKS cluster control plane
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_iam_role" "eks_admin" {
  name = "EKSAdminRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AllowAccountPrincipals",
      Effect = "Allow",
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.me.account_id}:root" },
      Action   = "sts:AssumeRole"
    }]
  })
}

data "aws_caller_identity" "me" {}

module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.31.6"

  depends_on   = [module.eks]                 # ensure cluster exists first
  manage_aws_auth_configmap = true           # this module manages it

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_admin.arn
      username = "admin:{{SessionName}}"
      groups   = ["system:masters"]          # cluster-admin
    }
  ]
}

