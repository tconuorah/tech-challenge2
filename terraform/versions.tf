terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
