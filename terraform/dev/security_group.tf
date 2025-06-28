resource "aws_security_group" "eks_cluster" {
  name_prefix = "${local.eks_cluster_name}-cluster-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name                                              = "${local.eks_cluster_name}-cluster-sg"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster_self_all" {
  security_group_id            = aws_security_group.eks_cluster.id
  description                  = "Cluster internal communication"
  referenced_security_group_id = aws_security_group.eks_cluster.id
  ip_protocol                  = "-1"

  tags = {
    Name = "cluster-self-all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster_from_nodes_https" {
  security_group_id            = aws_security_group.eks_cluster.id
  description                  = "HTTPS from worker nodes"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = {
    Name = "cluster-from-nodes-https"
  }
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_nodes_kubelet" {
  security_group_id            = aws_security_group.eks_cluster.id
  description                  = "Kubelet API to worker nodes"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"

  tags = {
    Name = "cluster-to-nodes-kubelet"
  }
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_nodes_https" {
  security_group_id            = aws_security_group.eks_cluster.id
  description                  = "HTTPS to worker nodes"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = {
    Name = "cluster-to-nodes-https"
  }
}

resource "aws_vpc_security_group_egress_rule" "cluster_dns_tcp" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "DNS TCP to VPC"
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"

  tags = {
    Name = "cluster-dns-tcp"
  }
}

resource "aws_vpc_security_group_egress_rule" "cluster_dns_udp" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "DNS UDP to VPC"
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"

  tags = {
    Name = "cluster-dns-udp"
  }
}

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${local.eks_cluster_name}-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name                                              = "${local.eks_cluster_name}-nodes-sg"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster_kubelet" {
  security_group_id            = aws_security_group.eks_nodes.id
  description                  = "Kubelet API from cluster"
  referenced_security_group_id = aws_security_group.eks_cluster.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"

  tags = {
    Name = "nodes-from-cluster-kubelet"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster_https" {
  security_group_id            = aws_security_group.eks_nodes.id
  description                  = "HTTPS from cluster"
  referenced_security_group_id = aws_security_group.eks_cluster.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = {
    Name = "nodes-from-cluster-https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_self_all" {
  security_group_id            = aws_security_group.eks_nodes.id
  description                  = "Node to node communication"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  ip_protocol                  = "-1"

  tags = {
    Name = "nodes-self-all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_alb_nodeport" {
  security_group_id            = aws_security_group.eks_nodes.id
  description                  = "NodePort range from ALB"
  referenced_security_group_id = aws_security_group.eks_alb.id
  from_port                    = 30000
  to_port                      = 32767
  ip_protocol                  = "tcp"

  tags = {
    Name = "nodes-from-alb-nodeport"
  }
}

resource "aws_vpc_security_group_egress_rule" "nodes_to_cluster_https" {
  security_group_id            = aws_security_group.eks_nodes.id
  description                  = "HTTPS to cluster"
  referenced_security_group_id = aws_security_group.eks_cluster.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = {
    Name = "nodes-to-cluster-https"
  }
}

resource "aws_vpc_security_group_egress_rule" "nodes_https_internet" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "HTTPS to internet for ECR/EKS APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Name = "nodes-https-internet"
  }
}

resource "aws_vpc_security_group_egress_rule" "nodes_ntp" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "NTP to internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 123
  to_port           = 123
  ip_protocol       = "udp"

  tags = {
    Name = "nodes-ntp"
  }
}

resource "aws_vpc_security_group_egress_rule" "nodes_dns_tcp" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "DNS TCP to VPC"
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"

  tags = {
    Name = "nodes-dns-tcp"
  }
}

resource "aws_vpc_security_group_egress_rule" "nodes_dns_udp" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "DNS UDP to VPC"
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"

  tags = {
    Name = "nodes-dns-udp"
  }
}

resource "aws_security_group" "eks_alb" {
  name_prefix = "${local.eks_cluster_name}-alb-"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.eks_cluster_name}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.eks_alb.id
  description       = "HTTP from internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name = "alb-http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.eks_alb.id
  description       = "HTTPS from internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Name = "alb-https"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_to_nodes_nodeport" {
  security_group_id            = aws_security_group.eks_alb.id
  description                  = "NodePort range to worker nodes"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 30000
  to_port                      = 32767
  ip_protocol                  = "tcp"

  tags = {
    Name = "alb-to-nodes-nodeport"
  }
}
resource "aws_security_group" "session_manager_bastion" {
  name_prefix = "${local.eks_cluster_name}-session-manager-bastion-"
  description = "Security group for Session Manager Bastion host"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.eks_cluster_name}-session-manager-bastion-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "session_manager_https" {
  security_group_id = aws_security_group.session_manager_bastion.id
  description       = "HTTPS for package downloads and AWS APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Name = "session-manager-https"
  }
}

resource "aws_vpc_security_group_egress_rule" "session_manager_dns_tcp" {
  security_group_id = aws_security_group.session_manager_bastion.id
  description       = "DNS TCP"
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"

  tags = {
    Name = "session-manager-dns-tcp"
  }
}

resource "aws_vpc_security_group_egress_rule" "session_manager_dns_udp" {
  security_group_id = aws_security_group.session_manager_bastion.id
  description       = "DNS UDP"
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"

  tags = {
    Name = "session-manager-dns-udp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster_from_bastion" {
  security_group_id            = aws_security_group.eks_cluster.id
  description                  = "HTTPS from Session Manager bastion"
  referenced_security_group_id = aws_security_group.session_manager_bastion.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = {
    Name = "cluster-from-bastion"
  }
}