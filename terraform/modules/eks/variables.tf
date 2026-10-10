variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "wild-tour-eks"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be provisioned"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS control plane (must include at least 2 subnets across AZs)"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Private Subnet IDs where worker nodes will run"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM Role ARN for the EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM Role ARN for the EKS managed node groups"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "capacity_type" {
  description = "Capacity type for worker nodes (ON_DEMAND or SPOT for cost savings)"
  type        = string
  default     = "SPOT"
}

variable "disk_size" {
  description = "Root EBS volume size in GB for worker nodes"
  type        = number
  default     = 20
}
