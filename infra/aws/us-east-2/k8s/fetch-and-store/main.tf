terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "s3" {}
}

variable "cluster_name" {
  type = string
}

variable "cluster_oidc_provider_arn" {
  type      = string
  sensitive = true
}

variable "cluster_region" {
  type = string
}

variable "cluster_profile" {
  type    = string
  default = "default"
}

variable "addon_namespace" {
  type    = string
  default = "kube-system"
}

variable "addon_version" {
  type    = string
  default = "3.13.0"
}

variable "image_repo" {
  type      = string
  sensitive = true
}

variable "image_tag" {
  type      = string
  sensitive = true
}

provider "aws" {
  region  = var.cluster_region
  profile = var.cluster_profile
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

module "fetch-and-store" {
  source = "../../../../../modules/k8s/bootstrap/fetch-and-store"

  cluster_name              = var.cluster_name
  cluster_oidc_provider_arn = var.cluster_oidc_provider_arn
  namespace                 = var.addon_namespace
  image_repo                = var.image_repo
  image_tag                 = var.image_tag
}
