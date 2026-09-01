# Defense-Grade GitOps Landing Zone & DevSecOps Infrastructure
# Adheres to CIS AWS Foundations, CIS Kubernetes v1.8, and NIST SP 800-53 Rev 5

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = var.use_localstack ? "mock_key" : null
  secret_key                  = var.use_localstack ? "mock_secret" : null
  s3_use_path_style           = var.use_localstack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      eks        = var.localstack_endpoint
      ec2        = var.localstack_endpoint
      kms        = var.localstack_endpoint
      iam        = var.localstack_endpoint
      logs       = var.localstack_endpoint
      s3         = var.localstack_endpoint
    }
  }
}

# 1. Customer-Managed KMS Key with Automated Rotation (CIS AWS 2.8)
resource "aws_kms_key" "defense_master_key" {
  description             = "Defense-Grade Customer Managed Key for Envelope Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Compliance  = "CIS-AWS-2.8"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "defense_master_key_alias" {
  name          = "alias/${var.environment}-defense-master-key"
  target_key_id = aws_kms_key.defense_master_key.key_id
}

# 2. Zero-Trust Network Module
module "zero_trust_network" {
  source      = "./modules/zero_trust_network"
  environment = var.environment
  kms_key_arn = aws_kms_key.defense_master_key.arn
}

# 3. Hardened Cluster Module
module "hardened_cluster" {
  source      = "./modules/hardened_cluster"
  environment = var.environment
  subnet_ids  = module.zero_trust_network.private_subnet_ids
  kms_key_arn = aws_kms_key.defense_master_key.arn
}
