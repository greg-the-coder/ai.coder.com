terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}

output "manifest" {
  value = yamlencode({
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name        = var.name
      namespace   = var.namespace
      annotations = var.annotations
      labels      = var.labels
    }
  })
}