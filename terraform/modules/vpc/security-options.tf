# 本番環境向けEKSセキュリティグループ改善案

variable "enable_strict_security" {
  description = "Enable strict security mode with minimal required ports only"
  type        = bool
  default     = false
}

variable "pod_cidr_blocks" {
  description = "CIDR blocks for Pod communication (required if enable_strict_security is true)"
  type        = list(string)
  default     = []
}

variable "enable_monitoring" {
  description = "Enable monitoring ports for Prometheus/Grafana"
  type        = bool
  default     = false
}

variable "monitoring_source_cidrs" {
  description = "CIDR blocks that can access monitoring ports"
  type        = list(string)
  default     = []
}