variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "A map of subnet CIDRs to their types and availability zones"
  type = list(object({
    az           = string
    private_cidr = string
    public_cidr  = string
    tags         = map(string)
  }))
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
