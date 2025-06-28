set -euo pipefail

dnf update -y

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

if ! command -v aws &> /dev/null; then
    log "Installing AWS CLI..."
    dnf install -y aws-cli
else
    log "AWS CLI already installed"
fi

mkdir -p /home/ec2-user/.kube
chown ec2-user:ec2-user /home/ec2-user/.kube

sudo -u ec2-user aws eks update-kubeconfig --region ${aws_region} --name ${eks_cluster_name}

sudo -u ec2-user kubectl version --client

echo "kubectl installation completed"