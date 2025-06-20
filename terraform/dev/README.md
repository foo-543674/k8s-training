# K8s Training - Dev Environment

このディレクトリには、k8s-training プロジェクトの開発環境用 Terraform 設定が含まれています。

## 構成要素

- **VPC**: Amazon EKS に最適化された VPC
- **サブネット**: パブリック・プライベートサブネット（2つのAZ）
- **NAT Gateway**: プライベートサブネットのインターネットアクセス用
- **Internet Gateway**: パブリックサブネットのインターネットアクセス用

## セットアップ手順

### 1. AWS認証情報の設定

```bash
# AWS CLIまたは環境変数で設定
aws configure
# または
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-northeast-1"
```

### 2. Terraform設定ファイルの作成

```bash
# terraform.tfvars.example をコピーして設定をカスタマイズ
cp terraform.tfvars.example terraform.tfvars
```

### 3. Terraform実行

```bash
# 初期化
terraform init

# プランの確認
terraform plan

# リソースの作成
terraform apply
```

## 設定のカスタマイズ

### terraform.tfvars での主要設定

```hcl
# リージョン設定
aws_region = "ap-northeast-1"

# プロジェクト情報
project_name = "k8s-training"
environment = "dev"

# ネットワーク設定
vpc_cidr = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

# コスト最適化 vs 高可用性
single_nat_gateway = false      # true: コスト重視（単一NAT Gateway）
one_nat_gateway_per_az = true   # true: 高可用性重視（AZごとにNAT Gateway）
```

## ネットワーク設計

```
VPC (10.0.0.0/16)
├── Public Subnet AZ-1a  (10.0.101.0/24)  # ALB, NAT Gateway
├── Public Subnet AZ-1c  (10.0.102.0/24)  # ALB, NAT Gateway
├── Private Subnet AZ-1a (10.0.1.0/24)    # EKS Worker Nodes
└── Private Subnet AZ-1c (10.0.2.0/24)    # EKS Worker Nodes
```

## EKS用最適化

このVPC設定にはEKS向けの最適化が含まれています：

- **サブネットタグ**: Load Balancer配置用のタグ設定
- **DNS設定**: EKS要件に準拠したDNS設定
- **高可用性**: 複数AZでの冗長構成

## 次のステップ

VPC作成後は以下のリソースを順次構築：

1. **Security Groups** - EKS用セキュリティグループ
2. **IAM Roles** - EKSクラスター用IAMロール
3. **EKS Cluster** - Kubernetesクラスター
4. **Node Groups** - Workerノード
5. **ALB** - Application Load Balancer

## 出力値

このTerraform設定は以下の値を出力します：

- `vpc_id`: 後続のリソース作成で使用
- `private_subnets`: EKS Node Groups配置用
- `public_subnets`: ALB配置用
- `azs`: 選択されたAvailability Zones

## トラブルシューティング

### よくある問題

1. **権限エラー**: IAMユーザーにVPC作成権限があることを確認
2. **リージョンエラー**: terraform.tfvarsのaws_regionが正しいことを確認
3. **CIDR重複**: 既存VPCとCIDRが重複していないことを確認

### リソースの削除

```bash
terraform destroy
```

**注意**: NAT Gatewayは課金対象のため、使用しない場合は削除してください。
