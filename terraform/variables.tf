variable "region" {
  type    = string
  default = "us-east-2"
}

variable "aws_profile" {
  type    = string
  default = "tc2"
}

variable "cluster_name" {
  type    = string
  default = "tc2-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

# Desired node group size & instance type
variable "min_size" {
  type    = number
  default = 3
}

variable "desired_size" {
  type    = number
  default = 3
}

variable "max_size" {
  type    = number
  default = 4
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
