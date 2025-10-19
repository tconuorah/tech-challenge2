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

data "aws_caller_identity" "me" {}

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

# (Optional) lets callers run update-kubeconfig
resource "aws_iam_role_policy" "eks_describe" {
  name = "EKSDescribeClusterOnly"
  role = aws_iam_role.eks_admin.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Action=["eks:DescribeCluster"], Resource="*" }]
  })
}


