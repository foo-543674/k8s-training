# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.name}-${var.environment}-eks-cluster-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for EKS cluster control plane"

  # Egress - Allow communication to worker nodes
  egress {
    from_port   = local.current_security_config.cluster_to_worker_port_range.from_port
    to_port     = local.current_security_config.cluster_to_worker_port_range.to_port
    protocol    = "tcp"
    cidr_blocks = var.pod_cidr_blocks
    description = "Communication to worker nodes"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.pod_cidr_blocks
    description = "HTTPS communication to worker nodes"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-eks-cluster-sg"
      Type = "eks-cluster"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Worker Nodes Security Group
resource "aws_security_group" "eks_worker_nodes" {
  name_prefix = "${var.name}-${var.environment}-eks-worker-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for EKS worker nodes"

  # Ingress - From control plane
  ingress {
    from_port       = local.current_security_config.cluster_to_worker_port_range.from_port
    to_port         = local.current_security_config.cluster_to_worker_port_range.to_port
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
    description     = "Communication from EKS control plane"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
    description     = "HTTPS from control plane"
  }

  # Kubelet API
  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
    description     = "Kubelet API"
  }

  # Pod-to-Pod communication within VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.pod_cidr_blocks
    description = "Pod to Pod communication"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = var.pod_cidr_blocks
    description = "Pod to Pod UDP communication"
  }

  # NodePort range (conditional)
  dynamic "ingress" {
    for_each = local.current_security_config.enable_node_port_range ? [1] : []
    content {
      from_port       = 30000
      to_port         = 32767
      protocol        = "tcp"
      security_groups = [aws_security_group.alb.id]
      description     = "NodePort range from ALB"
    }
  }

  # SSH access (conditional)
  dynamic "ingress" {
    for_each = var.enable_ssh_access && length(var.ssh_source_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_source_cidr_blocks
      description = "SSH access from trusted networks"
    }
  }

  # Monitoring ports (conditional)
  dynamic "ingress" {
    for_each = var.monitoring_enabled && length(var.monitoring_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = var.monitoring_cidr_blocks
      description = "Prometheus Node Exporter"
    }
  }

  dynamic "ingress" {
    for_each = var.monitoring_enabled && length(var.monitoring_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 4194
      to_port     = 4194
      protocol    = "tcp"
      cidr_blocks = var.monitoring_cidr_blocks
      description = "cAdvisor metrics"
    }
  }

  # Additional ingress rules
  dynamic "ingress" {
    for_each = var.additional_worker_ingress_rules
    content {
      from_port                = ingress.value.from_port
      to_port                  = ingress.value.to_port
      protocol                 = ingress.value.protocol
      cidr_blocks              = ingress.value.cidr_blocks
      source_security_group_id = ingress.value.source_security_group_id
      description              = ingress.value.description
    }
  }

  # Egress rules
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.https_cidr_blocks
    description = "HTTPS for container registries and AWS APIs"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = local.dns_cidr_blocks
    description = "DNS TCP"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = local.dns_cidr_blocks
    description = "DNS UDP"
  }

  egress {
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NTP"
  }

  # Pod-to-Pod egress within VPC
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.pod_cidr_blocks
    description = "Pod to Pod egress"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = var.pod_cidr_blocks
    description = "Pod to Pod UDP egress"
  }

  # Additional egress rules
  dynamic "egress" {
    for_each = var.additional_worker_egress_rules
    content {
      from_port                = egress.value.from_port
      to_port                  = egress.value.to_port
      protocol                 = egress.value.protocol
      cidr_blocks              = egress.value.cidr_blocks
      source_security_group_id = egress.value.target_security_group_id
      description              = egress.value.description
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-eks-worker-sg"
      Type = "eks-worker-nodes"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-${var.environment}-alb-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Application Load Balancer"

  # Ingress - HTTP/HTTPS from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access from internet"
  }

  # Egress - To worker nodes only
  dynamic "egress" {
    for_each = local.current_security_config.enable_node_port_range ? [1] : []
    content {
      from_port       = 30000
      to_port         = 32767
      protocol        = "tcp"
      security_groups = [aws_security_group.eks_worker_nodes.id]
      description     = "To worker nodes NodePort range"
    }
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker_nodes.id]
    description     = "HTTP to worker nodes"
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker_nodes.id]
    description     = "HTTPS to worker nodes"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-alb-sg"
      Type = "alb"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
