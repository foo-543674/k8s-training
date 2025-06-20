# VPC Module - EKS Security Optimized

このモジュールは、Amazon EKS に最適化されたVPCとセキュリティグループを作成し、**本番環境レベルのセキュリティ設定**を提供します。

## 🛡️ セキュリティ重視設計

### 汎用的なラッパーではなく、EKS特化設計
- **Pod CIDR制限**: 0.0.0.0/0ではなく、具体的なPod通信範囲を指定
- **セキュリティレベル選択**: strict/standard/permissive の3段階
- **具体的なエンドポイント制限**: コンテナレジストリ、DNS サーバーの明示的指定
- **運用考慮**: 監視、管理アクセスの適切な制限

## 📊 セキュリティレベル

### 🔒 Strict (本番推奨)
```hcl
security_level = "strict"
```
- コントロールプレーン → ワーカー: HTTPS(443)のみ
- DNS: 指定されたサーバーのみ
- HTTPS: 指定されたエンドポイントのみ
- Pod間通信: VPC CIDR内のみ

### ⚖️ Standard (開発・ステージング)
```hcl
security_level = "standard"
```
- コントロールプレーン → ワーカー: 1025-65535
- DNS: 全サーバー許可
- HTTPS: 全エンドポイント許可
- NodePort範囲: 有効

### 🔓 Permissive (レガシー互換)
```hcl
security_level = "permissive"
```
- 従来互換設定（本番非推奨）

## 🌐 ネットワーク設計例

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name        = "production-app"
  environment = "prod"

  # Network Configuration
  vpc_cidr               = "10.0.0.0/16"
  availability_zones     = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs    = ["10.0.101.0/24", "10.0.102.0/24"]

  # EKS Configuration
  cluster_name         = "production-cluster"
  pod_cidr_blocks      = ["10.0.0.0/16"]        # VPC内Pod通信のみ
  service_cidr_block   = "172.20.0.0/16"

  # Security Configuration
  security_level                = "strict"       # 本番環境用
  trusted_cidr_blocks           = ["10.0.0.0/16"] # 管理アクセス範囲
  
  # 具体的なエンドポイント制限
  container_registry_endpoints  = [
    "*.amazonaws.com",    # ECR
    "gcr.io"             # 必要な外部レジストリのみ
  ]
  
  allowed_dns_servers = [
    "169.254.169.253"    # AWS DNS のみ
  ]

  # 監視設定
  monitoring_enabled     = true
  monitoring_cidr_blocks = ["10.0.0.0/16"]

  # 本番では SSH 無効
  enable_ssh_access = false
}
```

## 🔧 カスタムルール例

```hcl
# 追加のアプリケーション通信
additional_worker_ingress_rules = [
  {
    description = "Database access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
]

additional_worker_egress_rules = [
  {
    description = "External API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # 特定のAPI エンドポイント
  }
]
```

## 🏗️ 作成されるリソース

### ネットワーク
- VPC (EKS タグ付き)
- パブリック・プライベートサブネット (LoadBalancer タグ付き)
- インターネットゲートウェイ・NAT ゲートウェイ
- ルートテーブル

### セキュリティグループ (3種類)
1. **EKS Cluster**: コントロールプレーン用
2. **EKS Worker Nodes**: ワーカーノード用（レベル別設定）
3. **ALB**: Application Load Balancer用

## 🎯 設定比較

| 項目 | Permissive | Standard | Strict |
|------|------------|----------|--------|
| Cluster→Worker | 0-65535 | 1025-65535 | 443のみ |
| Pod間通信 | 全許可 | VPC内のみ | VPC内のみ |
| DNS | 全許可 | 全許可 | 指定のみ |
| HTTPS Egress | 全許可 | 全許可 | 指定のみ |
| SSH | 設定可能 | 設定可能 | 無効推奨 |
| 本番適用 | ❌ | ⚠️ | ✅ |

## 📈 段階的セキュリティ強化

### Phase 1: Standard で開始
```hcl
security_level = "standard"
enable_flow_log = true  # トラフィック分析
```

### Phase 2: 具体的制限追加
```hcl
container_registry_endpoints = ["*.amazonaws.com"]
allowed_dns_servers = ["169.254.169.253"]
```

### Phase 3: Strict へ移行
```hcl
security_level = "strict"
enable_ssh_access = false
```

## 🔍 トラブルシューティング

### VPC Flow Logs 有効化
```hcl
enable_flow_log = true
```

### 一時的なアクセス許可
```hcl
additional_worker_ingress_rules = [
  {
    description = "Temporary debug access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]  # 限定的な範囲
  }
]
```

## ⚠️ 重要な注意事項

1. **Pod CIDR 設計**: `pod_cidr_blocks` は実際の Pod ネットワーク設計と一致させる
2. **Service CIDR**: EKS クラスター作成時の設定と一致させる
3. **DNS 制限**: 厳密すぎると名前解決で問題が発生する可能性
4. **段階的適用**: 本番環境では段階的に制限を強化

## 🎯 次のステップ

1. **terraform plan** でセキュリティ設定確認
2. **VPC Flow Logs** で実際のトラフィック確認
3. **段階的な制限強化** で最適化
