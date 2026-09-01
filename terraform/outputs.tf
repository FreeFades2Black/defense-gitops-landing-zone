output "kms_key_arn" {
  value       = aws_kms_key.defense_master_key.arn
  description = "ARN of customer-managed KMS key"
}

output "vpc_id" {
  value       = module.zero_trust_network.vpc_id
  description = "ID of the zero-trust private VPC"
}

output "cluster_arn" {
  value       = module.hardened_cluster.cluster_arn
  description = "ARN of the hardened EKS cluster"
}

output "cluster_name" {
  value       = module.hardened_cluster.cluster_name
  description = "Name of the hardened EKS cluster"
}
