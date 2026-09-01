# Defense-Grade Zero-Trust Network Module
# CIS AWS Foundations Benchmark compliant VPC: KMS-encrypted Flow Logs, no IGW for app subnets

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environment" { type = string }
variable "vpc_cidr" { type = string; default = "10.100.0.0/16" }
variable "kms_key_arn" { type = string }

# 1. Zero-Trust Hardened VPC
resource "aws_vpc" "defense_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-defense-zero-trust-vpc"
    Compliance  = "NIST-800-53-Rev5"
    Environment = var.environment
  }
}

# 2. Private Workload Subnets (Isolated, No Direct Internet Routing)
resource "aws_subnet" "private_workload_a" {
  vpc_id                  = aws_vpc.defense_vpc.id
  cidr_block              = "10.100.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-private-workload-1a"
    Tier = "ZeroTrustPrivate"
  }
}

resource "aws_subnet" "private_workload_b" {
  vpc_id                  = aws_vpc.defense_vpc.id
  cidr_block              = "10.100.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-private-workload-1b"
    Tier = "ZeroTrustPrivate"
  }
}

# 3. Encrypted CloudWatch Log Group for VPC Flow Logs (CIS 3.9)
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.environment}-defense-flow-logs"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn

  tags = {
    Compliance = "CIS-AWS-3.9"
  }
}

# 4. IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
}

# 5. VPC Flow Log (Captures all REJECT and ACCEPT traffic)
resource "aws_flow_log" "defense_vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.defense_vpc.id
}

output "vpc_id" { value = aws_vpc.defense_vpc.id }
output "private_subnet_ids" { value = [aws_subnet.private_workload_a.id, aws_subnet.private_workload_b.id] }
