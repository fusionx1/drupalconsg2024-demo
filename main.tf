terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  access_key = var.access_key
  secret_key = var.secret_key
 
}

module "vpc" {
  source = "./modules/vpc/"
  tags   = var.tags
}

module "rds" {
  source     = "./modules/rds"
  tags       = var.tags
  vpc        = module.vpc
  ecs_sg     = module.ecs.ecs_sg
  subnet_ids = keys(module.vpc.public_subnets)
}

module "load_balancer" {
  source  = "./modules/alb"
  tags    = var.tags
  vpc_id  = module.vpc.id
  subnets = module.vpc.public_subnets
}

module "ecs" {
  source           = "./modules/ecs"
  tags             = var.tags
  vpc_id           = module.vpc.id
  vpc_subnets      = keys(module.vpc.public_subnets)
  lb_sg            = module.load_balancer.security_group
  lb_tg_arn        = module.load_balancer.target_group_arn
  efs_fs_id        = module.efs.fs_id
  efs_access_point = module.efs.files_access_point
}

module "efs" {
  source  = "./modules/efs"
  tags    = var.tags
  ecs_sg  = module.ecs.ecs_sg
  vpc_id  = module.vpc.id
  subnets = module.vpc.public_subnets
}