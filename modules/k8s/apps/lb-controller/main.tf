terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

variable "path" {
  type = string
}

variable "namespace" {
  type = string
}

variable "aws_lb_controller_helm_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "enable_cert_manager" {
  type    = bool
  default = false
}

variable "service_target_eni_sg_tags" {
  type    = map(string)
  default = {}
}

variable "service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "cluster_asg_node_labels" {
  type    = map(string)
  default = {}
}

locals {
  service_target_eni_sg_tags = join(",", [
    for k, v in var.service_target_eni_sg_tags : "${k}=${v}"
  ])
}

module "kustomization" {
  source    = "../../objects/kustomization"
  namespace = var.namespace
  helm_charts = [{
    name         = "aws-load-balancer-controller"
    release_name = "eks"
    repo         = "https://aws.github.io/eks-charts"
    namespace    = var.namespace
    include_crds = true
    version      = var.aws_lb_controller_helm_version
    values_file  = "./values.yaml"
  }]
}

resource "local_file" "kustomization" {
  filename = "${var.path}/kustomization.yaml"
  content  = module.kustomization.manifest
}

resource "local_file" "values" {
  filename = "${var.path}/values.yaml"
  content = yamlencode({
    clusterName = var.cluster_name
    serviceAccount = {
      create                       = true
      annotations                  = var.service_account_annotations
      automountServiceAccountToken = true
      imagePullSecrets             = []
    }
    nodeSelector           = var.cluster_asg_node_labels
    enableCertManager      = var.enable_cert_manager
    serviceTargetENISGTags = local.service_target_eni_sg_tags
  })
}