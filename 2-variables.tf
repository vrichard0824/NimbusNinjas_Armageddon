variable "instance_type" {
  default = "t3.micro"
}

variable "ami_ids" {
  type = map(string)
  # Provide valid AMIs per region
  default = {
    tokyo      = "ami-023ff3d4ab11b2525"
    newyork    = "ami-063d43db0594b521b"
    london     = "ami-0c76bd4bd302b30ec"
    saopaulo   = "ami-0c820c196a818d66a" #amazon linux 2023 t2
    australia  = "ami-0146fc9ad419e2cfd"
    hongkong   = "ami-06f707739f2271995" #T3 Micro
    california = "ami-038bba9a164eb3dc1"
  }
}

# Common CIDRs (adjust as needed)
variable "vpc_cidr" {
  default = "10.110.0.0/16"
}

variable "subnet_az1_cidr" {
  default = "10.110.1.0/24"
}

variable "subnet_az2_cidr" {
  default = "10.110.2.0/24"
}