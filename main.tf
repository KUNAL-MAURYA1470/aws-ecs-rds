locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "${local.name_prefix}-app"

  tags = local.common_tags
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix

  ecs_task_execution_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]

  ecs_task_additional_policies = []

  tags = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  db_name                    = var.db_name
  db_username                = var.db_username
  backup_retention_period    = var.db_backup_retention_period
  multi_az                   = var.db_multi_az
  rotation_lambda_filename   = var.db_rotation_lambda_filename
  rotation_lambda_subnet_ids = module.vpc.private_subnet_ids
  rotation_lambda_security_group_ids = [
    module.vpc.private_default_security_group_id
  ]

  tags = local.common_tags
}

module "alb" {
  source = "./modules/alb"

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  idle_timeout      = var.alb_idle_timeout

  tags = local.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix          = local.name_prefix
  cluster_name         = "${local.name_prefix}-cluster"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  ecs_desired_count    = var.ecs_desired_count
  ecs_min_capacity     = var.ecs_min_capacity
  ecs_max_capacity     = var.ecs_max_capacity
  container_cpu        = var.ecs_container_cpu
  container_memory     = var.ecs_container_memory
  container_port       = var.ecs_container_port
  container_image      = var.ecs_task_image
  alb_target_group_arn = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  ecs_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  log_group_name         = module.iam.ecs_log_group_name
  db_secret_arn          = module.rds.db_secret_arn
  db_hostname            = module.rds.db_endpoint
  db_port                = module.rds.db_port
  db_name                = module.rds.db_name
  db_username            = module.rds.db_username

  tags = local.common_tags
}

resource "aws_security_group_rule" "rds_ingress_from_ecs" {
  description              = "Allow Postgres from ECS service security group"
  type                     = "ingress"
  from_port                = module.rds.db_port
  to_port                  = module.rds.db_port
  protocol                 = "tcp"
  security_group_id        = module.rds.security_group_id
  source_security_group_id = module.ecs.service_security_group_id
}

module "waf" {
  source = "./modules/waf"

  name_prefix = local.name_prefix
  alb_arn     = module.alb.alb_arn
  rate_limit  = var.waf_rate_limit
  scope       = "REGIONAL"

  tags = local.common_tags
}

