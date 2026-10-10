# ==============================================================================
# Terraform Remote State & Distributed State-Locking Configuration
# ==============================================================================
# S3 provides encrypted, versioned remote state storage.
# DynamoDB provides distributed state locking via LockID to prevent concurrent writes.

terraform {
  backend "s3" {
    bucket         = "wild-tour-eks-tfstate-123456789012"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "wild-tour-eks-tflocks"
    encrypt        = true
  }
}
