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

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# EKS Network Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "pod_cidr_blocks" {
  description = "CIDR blocks used by EKS for Pod networking"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "service_cidr_block" {
  description = "CIDR block for Kubernetes services"
  type        = string
  default     = "172.20.0.0/16"
}

# Security Configuration
variable "security_level" {
  description = "Security level: 'strict', 'standard', 'permissive'"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["strict", "standard", "permissive"], var.security_level)
    error_message = "Security level must be one of: strict, standard, permissive."
  }
}

variable "trusted_cidr_blocks" {
  description = "CIDR blocks that are trusted for management access"
  type        = list(string)
  default     = []
}

variable "monitoring_enabled" {
  description = "Enable monitoring ports (Prometheus, etc.)"
  type        = bool
  default     = false
}

variable "monitoring_cidr_blocks" {
  description = "CIDR blocks that can access monitoring endpoints"
  type        = list(string)
  default     = []
}

variable "container_registry_endpoints" {
  description = "Specific endpoints for container registries (ECR, etc.)"
  type        = list(string)
  default     = []
}

variable "allowed_dns_servers" {
  description = "Specific DNS servers to allow (empty means allow all)"
  type        = list(string)
  default     = []
}

# NAT Gateway Configuration
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost optimization"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Use one NAT Gateway per AZ for high availability"
  type        = bool
  default     = true
}

# VPC Flow Logs
variable "enable_flow_log" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

# Additional Rules
variable "additional_worker_ingress_rules" {
  description = "Additional ingress rules for worker nodes"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    source_security_group_id = optional(string, null)
  }))
  default = []
}

variable "additional_worker_egress_rules" {
  description = "Additional egress rules for worker nodes"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    target_security_group_id = optional(string, null)
  }))
  default = []
}

# Legacy SSH Support
variable "enable_ssh_access" {
  description = "Enable SSH access to worker nodes (not recommended for production)"
  type        = bool
  default     = false
}

variable "ssh_source_cidr_blocks" {
  description = "CIDR blocks that can SSH to worker nodes"
  type        = list(string)
  default     = []
}
