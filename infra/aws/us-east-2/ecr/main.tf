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

variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "account_id" {
  type = string
}

variable "cross_account_id" {
  type = string
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

locals {
  default = [{
    sid    = "AccessPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DeleteRepository",
      "ecr:DeleteRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:SetRepositoryPolicy",
      "ecr:UploadLayerPart"
    ]
    principals = [{
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:root",
        "arn:aws:iam::${var.cross_account_id}:root"
      ]
    }]
  }]
}

module "base-ws-image" {
  source    = "./repository"
  repo-name = "base-ws"
}

module "base-ws-image-policy" {
  source                = "./policy"
  repo-name             = module.base-ws-image.repository_name
  iam_policy_statements = local.default
}

module "claude-ws-image" {
  source    = "./repository"
  repo-name = "claude-ws"
}

module "claude-ws-image-policy" {
  source                = "./policy"
  repo-name             = module.claude-ws-image.repository_name
  iam_policy_statements = local.default
}

module "goose-ws-image" {
  source    = "./repository"
  repo-name = "goose-ws"
}

module "goose-ws-image-policy" {
  source                = "./policy"
  repo-name             = module.goose-ws-image.repository_name
  iam_policy_statements = local.default
}

module "fetch-and-store-image" {
  source    = "./repository"
  repo-name = "fetch-and-store"
}

module "fetch-and-store-image-policy" {
  source                = "./policy"
  repo-name             = module.fetch-and-store-image.repository_name
  iam_policy_statements = local.default
}

module "coder-preview-image" {
  source    = "./repository"
  repo-name = "coder-preview"
}

module "coder-preview-image-policy" {
  source                = "./policy"
  repo-name             = module.coder-preview-image.repository_name
  iam_policy_statements = local.default
}

output "account_id" {
  value = var.account_id
}

output "region" {
  value = var.region
}