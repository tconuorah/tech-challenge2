module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${var.region}a", "${var.region}b"]
  public_subnets = ["10.0.0.0/20", "10.0.16.0/20"]

  # Correct flag (applies to the public subnets the module creates)
  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
}
