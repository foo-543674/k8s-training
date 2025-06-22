locals {
  eks_cluster_name = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  )
}