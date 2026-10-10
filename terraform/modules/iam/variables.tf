variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "wild-tour-eks"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}
