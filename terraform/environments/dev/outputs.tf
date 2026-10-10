output "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs for EKS worker nodes"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public Subnet IDs for ingress and ALBs"
  value       = module.vpc.public_subnet_ids
}

output "cluster_name" {
  description = "The name of the provisioned EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL for the EKS Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security Group ID of the EKS cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OpenID Connect (OIDC) identity provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl_command" {
  description = "AWS CLI command to update local kubeconfig for cluster access"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
