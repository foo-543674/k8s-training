variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "k8s-training"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnet configuration for private subnets for each az"
  type = list(object({
    az           = string
    private_cidr = string
    public_cidr  = string
  }))
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
  default     = 5
}

variable "local_allowed_cidrs" {
  description = "List of CIDRs allowed to access the EKS cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}