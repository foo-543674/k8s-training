# EKS セキュリティグループ - 本番環境向け設定

本ファイルでは、本番環境に適したEKSセキュリティグループの設定について説明します。

## 現在の設定の改善点

### ✅ 改善済み項目
- ワーカーノードのEgress制限（HTTPS、DNS のみ）
- ALBのEgress制限（HTTP/HTTPS のみ）
- 具体的なポート指定（Kubelet API等）
- 不要な全ポート許可の削除

### 🔧 追加検討事項

#### 1. Pod間通信
```hcl
# Pod間通信用（VPC内でのPod CIDR範囲）
ingress {
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]  # VPC CIDR範囲に制限
  description = "Pod to Pod communication within VPC"
}
```

#### 2. 監視・メトリクス収集
```hcl
# Prometheus Node Exporter
ingress {
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = var.monitoring_sg_id
  description              = "Prometheus Node Exporter"
}

# cAdvisor
ingress {
  from_port = 4194
  to_port   = 4194
  protocol  = "tcp"
  self      = true
  description = "cAdvisor metrics"
}
```

#### 3. CNI関連ポート
```hcl
# AWS VPC CNI
ingress {
  from_port = 61678
  to_port   = 61678
  protocol  = "tcp"
  self      = true
  description = "AWS VPC CNI"
}
```

## 推奨セキュリティ設定レベル

### レベル1: 最小権限（現在の設定）
- 必要最小限のポートのみ開放
- 具体的なポート番号指定
- 送信元セキュリティグループ指定

### レベル2: 監視対応
- メトリクス収集用ポート追加
- ログ転送用ポート追加
- 健康チェック用ポート追加

### レベル3: 本番運用
- サービスメッシュ対応
- トレーシング対応
- 災害復旧対応

## セキュリティベストプラクティス

1. **最小権限の原則**: 必要最小限のポートのみ開放
2. **送信元制限**: CIDR範囲やセキュリティグループIDで制限
3. **定期的な見直し**: 不要なルールの削除
4. **ログ監視**: VPC Flow Logsでトラフィック監視
5. **定期的な脆弱性スキャン**: セキュリティグループ設定の監査

## トラフィックフロー

```
Internet → ALB (80/443) → Worker Nodes (30000-32767)
Control Plane (443) → Worker Nodes (1025-65535) ※要見直し
Worker Nodes → Internet (443: HTTPS, 53: DNS)
```

## 改善提案

現在の `1025-65535` は範囲が広すぎる可能性があります：

```hcl
# より具体的なポート指定への変更案
ingress {
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_groups          = [aws_security_group.eks_cluster.id]
  description              = "HTTPS from control plane"
}

ingress {
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_groups          = [aws_security_group.eks_cluster.id]
  description              = "Kubelet API from control plane"
}
```
