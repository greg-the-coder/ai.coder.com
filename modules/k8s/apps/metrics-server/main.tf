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

variable "metrics_server_helm_version" {
  type = string
}

variable "values_inline" {
  type    = map(any)
  default = {}
}

locals {
  kustomization_file = "kustomization.yaml"
}

module "kustomization" {
  source    = "../../objects/kustomization"
  namespace = var.namespace
  helm_charts = [{
    name          = "metrics-server"
    release_name  = "metrics-server"
    repo          = "https://kubernetes-sigs.github.io/metrics-server/"
    version       = var.metrics_server_helm_version
    namespace     = var.namespace
    include_crds  = true
    values_inline = var.values_inline
  }]
}

resource "local_file" "kustomization" {
  filename = join("/", [var.path, local.kustomization_file])
  content  = module.kustomization.manifest
}