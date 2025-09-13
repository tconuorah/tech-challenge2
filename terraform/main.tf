module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  private_subnets = ["10.0.48.0/20","10.0.64.0/20","10.0.80.0/20"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

data "aws_availability_zones" "available" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_enabled_log_types = ["api", "authenticator", "controllerManager", "scheduler"]

  cluster_endpoint_public_access = true
  enable_irsa                     = true

  eks_managed_node_groups = {
    ng = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = [var.node_instance]
      capacity_type  = "ON_DEMAND"
    }
  }
}

# -------- IRSA for AWS Load Balancer Controller --------
# Create the policy from official JSON saved locally:
# terraform/iam_policies/aws_load_balancer_controller.json
data "aws_iam_policy_document" "lb_sa_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_policy" "lb_controller" {
  name   = "${var.cluster_name}-AWSLoadBalancerController"
  policy = file("${path.module}/iam_policies/aws_load_balancer_controller.json")
}

resource "aws_iam_role" "lb_controller" {
  name               = "${var.cluster_name}-alb-sa-role"
  assume_role_policy = data.aws_iam_policy_document.lb_sa_trust.json
}

resource "aws_iam_role_policy_attachment" "lb_attach" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

output "cluster_name"   { value = module.eks.cluster_name }
output "cluster_region" { value = var.region }
output "vpc_id"         { value = module.vpc.vpc_id }
output "private_subnets"{ value = module.vpc.private_subnets }
