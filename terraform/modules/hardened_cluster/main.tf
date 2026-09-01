# Defense-Grade Hardened Cluster Module
# Enforces CIS EKS Benchmark: Secrets envelope encryption, private API endpoint, audit logging

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environment" { type = string }
variable "subnet_ids" { type = list(string) }
variable "kms_key_arn" { type = string }

# 1. Cluster IAM Role
resource "aws_iam_role" "cluster_role" {
  name = "${var.environment}-defense-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# 2. Hardened EKS Cluster with Envelope Encryption (CIS 2.1)
resource "aws_eks_cluster" "defense_cluster" {
  name     = "${var.environment}-defense-hardened-eks"
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false # CIS Requirement: Zero Public Kubernetes API
  }

  # CIS EKS 2.1: Envelope Encryption for Kubernetes Secrets
  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  # CIS EKS 3.1: Control Plane Audit & Diagnostic Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]

  tags = {
    Classification = "Secret-Level-Simulated"
    Compliance     = "CIS-Kubernetes-v1.8"
    Environment    = var.environment
  }
}

output "cluster_name" { value = aws_eks_cluster.defense_cluster.name }
output "cluster_arn" { value = aws_eks_cluster.defense_cluster.arn }
output "cluster_endpoint" { value = aws_eks_cluster.defense_cluster.endpoint }
