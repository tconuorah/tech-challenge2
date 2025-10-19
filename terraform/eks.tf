module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6" # a v20.x release with stable inputs

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version

  # PUBLIC API endpoint (what you asked for)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.instance_type]
      min_size       = var.min_size
      desired_size   = var.desired_size
      max_size       = var.max_size
      subnet_ids     = module.vpc.private_subnets
      attach_cluster_primary_security_group = true
    }
  }
  
  
  # Optional tags
  tags = { Project = "TC2", Env = "dev" }
}
