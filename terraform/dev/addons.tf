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

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }
  }

  depends_on = [aws_eks_node_group.main]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.13.3"

  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.main.name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    }
  ]

  depends_on = [
    aws_eks_pod_identity_association.aws_load_balancer_controller,
    aws_iam_role_policy_attachment.aws_load_balancer_controller,
    aws_eks_addon.pod_identity
  ]
}