variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS Region"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Target deployment environment (dev, staging, prod)"
}

variable "use_localstack" {
  type        = bool
  default     = false
  description = "Toggle LocalStack emulation for local zero-cost sandbox testing"
}

variable "localstack_endpoint" {
  type        = string
  default     = "http://localhost:4566"
  description = "LocalStack API endpoint URL"
}
