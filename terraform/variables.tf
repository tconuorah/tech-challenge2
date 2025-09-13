variable "region" {
  type    = string
  default = "us-east-2"
}

variable "cluster_name" {
  type = string
  default = "tc2-cluster"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "node_instance" {
  type = string
  default = "t3.micro"
}

variable "min_size" {
  type = number
  default = 1
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 4
}
