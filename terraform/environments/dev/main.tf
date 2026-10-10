# ==============================================================================
# Development Environment — Infrastructure Orchestration
# ==============================================================================

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  cluster_name              = var.cluster_name
  environment               = var.environment
  enable_single_nat_gateway = true
}

module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
  environment  = var.environment
}

module "eks" {
  source = "../../modules/eks"

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids  = module.vpc.private_subnet_ids
  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn
  instance_types   = var.instance_types
  capacity_type    = var.capacity_type
  desired_size     = var.node_desired_size
  min_size         = var.node_min_size
  max_size         = var.node_max_size

  depends_on = [
    module.vpc,
    module.iam
  ]
}
