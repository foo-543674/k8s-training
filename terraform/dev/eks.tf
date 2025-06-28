resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-eks-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.vpc.private_subnets

  instance_types = var.worker_node_instance_types
  ami_type       = var.worker_node_ami_type
  capacity_type  = var.worker_node_capacity_type
  disk_size      = 20

  scaling_config {
    desired_size = 1
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_policy,
    aws_iam_role_policy_attachment.eks_registry_policy
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-nodes"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "kubernetes_service_account_v1" "aws_node" {
  metadata {
    name      = "aws-node"
    namespace = "kube-system"
  }

  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = kubernetes_service_account_v1.aws_node.metadata[0].name
  role_arn        = aws_iam_role.vpc_cni.arn

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-cni-pod-identity"
    Environment = var.environment
    Project     = var.project_name
  }
}