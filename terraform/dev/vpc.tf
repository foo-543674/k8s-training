module "vpc" {
  source = "../modules/vpc"

  name        = var.project_name
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  subnets = [
    for subnet in var.subnets : {
      az           = subnet.az
      private_cidr = subnet.private_cidr
      public_cidr  = subnet.public_cidr
      tags         = {}
    }
  ]
}
