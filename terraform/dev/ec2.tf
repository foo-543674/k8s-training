data "aws_ami" "amazonlinux2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "session_manager_bastion" {
  ami           = data.aws_ami.amazonlinux2023.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.private_subnets[0]

  iam_instance_profile   = aws_iam_instance_profile.session_manager.name
  vpc_security_group_ids = [aws_security_group.session_manager_bastion.id]

  user_data_base64 = base64encode(templatefile("${path.module}/scripts/install-kubectl.sh", {
    eks_cluster_name = aws_eks_cluster.main.name
    aws_region       = var.aws_region
  }))

  tags = {
    Name = "${var.project_name}-${var.environment}-session-manager-bastion"
  }
}
