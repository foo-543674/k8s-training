# Basic Configuration
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

# Network Configuration - EKS Optimized
variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

# EKS Network Configuration
variable "pod_cidr_blocks" {
  description = "CIDR blocks used by EKS for Pod networking (for security group rules)"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Defaults to VPC CIDR, but can be more specific
}

variable "service_cidr_block" {
  description = "CIDR block for Kubernetes services"
  type        = string
  default     = "172.20.0.0/16"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# Security Configuration
variable "security_level" {
  description = "Security level: 'strict' (minimal ports), 'standard' (moderate), 'permissive' (legacy)"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["strict", "standard", "permissive"], var.security_level)
    error_message = "Security level must be one of: strict, standard, permissive."
  }
}

variable "trusted_cidr_blocks" {
  description = "CIDR blocks that are trusted for management access (SSH, monitoring)"
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

# Internet Access Configuration
variable "container_registry_endpoints" {
  description = "Specific endpoints for container registries (ECR, etc.) to restrict egress"
  type        = list(string)
  default     = []  # Empty means allow all HTTPS
}

variable "allowed_dns_servers" {
  description = "Specific DNS servers to allow (empty means allow all)"
  type        = list(string)
  default     = []
}

# NAT Gateway Configuration
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone"
  type        = bool
  default     = true
}

# DNS Configuration
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

# VPC Flow Logs
variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

# Additional Ports (for specific applications)
variable "additional_worker_ingress_rules" {
  description = "Additional ingress rules for worker nodes (specific applications)"
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
  description = "Additional egress rules for worker nodes (specific applications)"
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

# Legacy SSH Support (not recommended for production)
variable "enable_ssh_access" {
  description = "Enable SSH access to worker nodes (not recommended for production)"
  type        = bool
  default     = false
}

variable "ssh_source_cidr_blocks" {
  description = "CIDR blocks that can SSH to worker nodes (only if enable_ssh_access is true)"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
