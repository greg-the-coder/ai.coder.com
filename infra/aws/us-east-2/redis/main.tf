terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46"
    }
  }
  backend "s3" {}
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "master_password" {
  description = "Database root password"
  type        = string
  sensitive   = true
}

variable "name" {
  description = "Name of resource and tag prefix"
  type        = string
}

variable "region" {
  description = "The aws region for database deployment"
  type        = string
}

variable "private_subnet_ids" {
  description = "The deployed private subnet for the database"
  type        = list(string)
  sensitive   = true
}

variable "vpc_id" {
  description = "The deployed vpc id for the database"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "The allocated storage size in gb"
  default     = "20"
  type        = string
}

variable "engine_version" {
  description = "The version to deploy"
  default     = "15.7"
  type        = string
}

variable "instance_class" {
  description = "The size of db instance class to deploy"
  default     = "db.m5.large"
  type        = string
}

variable "profile" {
  type = string
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "redis" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  ip_protocol       = "tcp"
  from_port         = 6379
  to_port           = 6379
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name        = "redis-litellm"
  description = "Redis 6379 In. Allow All Out"
  tags = {
    Name = "redis-litellm"
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "redis-litellm"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "default" {
  replication_group_id       = "litellm"
  description                = "Valkey (i.e. Redis) Cluster for LiteLLM"
  node_type                  = "cache.r7g.large"
  port                       = 6379
  parameter_group_name       = "default.valkey8.cluster.on"
  security_group_ids         = [aws_security_group.this.id]
  automatic_failover_enabled = true
  engine                     = "valkey"
  engine_version             = "8.0"

  auth_token                 = var.master_password
  transit_encryption_enabled = true
  apply_immediately          = true

  subnet_group_name       = aws_elasticache_subnet_group.default.name
  num_node_groups         = 2
  replicas_per_node_group = 1
}