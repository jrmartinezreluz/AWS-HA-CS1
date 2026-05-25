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
  region = var.region
}

module "vpc" {
  source               = "./modules/vpc"
  project              = var.project
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "ec2" {
  source                     = "./modules/ec2"
  project                    = var.project
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnets
  public_subnet_ids          = module.vpc.public_subnets
  ami_id                     = var.ami_id
  instance_type              = var.instance_type
  key_name                   = var.key_name
  user_data                  = file("${path.module}/scripts/user_data.sh")
  enable_detailed_monitoring = var.enable_detailed_monitoring
}

module "rds" {
  source                  = "./modules/rds"
  project                 = var.project
  vpc_id                  = module.vpc.vpc_id
  db_subnet_ids           = module.vpc.private_subnets
  ec2_security_group_id   = module.ec2.security_group_id
  db_instance_type        = var.db_instance_type
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  allocated_storage       = var.allocated_storage
  engine_version          = var.engine_version
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
}
