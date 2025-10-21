provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Stay on v5 (modules in your stack expect v5). Do NOT allow v6.
      version = ">= 5.81.0, < 6.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}



