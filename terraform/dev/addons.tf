resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "vpc-cni"
  addon_version = "v1.18.0-eksbuild.3"

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-cni-addon"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  tags = {
    Name        = "${var.project_name}-${var.environment}-coredns-addon"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  tags = {
    Name        = "${var.project_name}-${var.environment}-kube-proxy-addon"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "pod-identity"

  tags = {
    Name        = "${var.project_name}-${var.environment}-pod-identity-addon"
    Environment = var.environment
    Project     = var.project_name
  }
}