locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.name
      ManagedBy   = "terraform"
    }
  )

  azs = distinct([for subnet in var.subnets : subnet.az])
}