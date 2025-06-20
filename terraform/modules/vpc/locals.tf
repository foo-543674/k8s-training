locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.name
      ManagedBy   = "terraform"
    }
  )

  # EKS requires specific tags for subnets
  public_subnet_tags = merge(
    local.common_tags,
    {
      "kubernetes.io/role/elb" = "1"
      Type                     = "public"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )

  private_subnet_tags = merge(
    local.common_tags,
    {
      "kubernetes.io/role/internal-elb" = "1"
      Type                              = "private"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  # Security level configurations
  security_configs = {
    strict = {
      cluster_to_worker_port_range = {
        from_port = 443
        to_port   = 443
      }
      enable_node_port_range = false
      dns_servers           = length(var.allowed_dns_servers) > 0 ? var.allowed_dns_servers : ["169.254.169.253"] # AWS DNS
      container_registries  = length(var.container_registry_endpoints) > 0 ? var.container_registry_endpoints : []
    }
    standard = {
      cluster_to_worker_port_range = {
        from_port = 1025
        to_port   = 65535
      }
      enable_node_port_range = true
      dns_servers           = ["0.0.0.0/0"] # Allow all DNS
      container_registries  = []             # Allow all HTTPS
    }
    permissive = {
      cluster_to_worker_port_range = {
        from_port = 0
        to_port   = 65535
      }
      enable_node_port_range = true
      dns_servers           = ["0.0.0.0/0"]
      container_registries  = []
    }
  }

  current_security_config = local.security_configs[var.security_level]

  # Determine egress CIDR blocks based on security level
  dns_cidr_blocks = local.current_security_config.dns_servers
  https_cidr_blocks = length(local.current_security_config.container_registries) > 0 ? 
    local.current_security_config.container_registries : ["0.0.0.0/0"]
}