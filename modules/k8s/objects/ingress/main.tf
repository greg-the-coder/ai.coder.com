terraform {}

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

variable "ingress_class_name" {
  type = string
}

variable "rules" {
  type = list(object({
    host = string
    http = object({
      paths = list(object({
        path      = string
        path_type = string
        backend = object({
          service = object({
            name = string
            port = object({
              number = number
            })
          })
        })
      }))
    })
  }))
  default = []
}

locals {
  rules = [for v in var.rules : {
    host = v.host
    http = {
      paths = [for p in v.http.paths : {
        path     = p.path
        pathType = p.path_type
        backend  = p.backend
      }]
    }
  }]
}

output "manifest" {
  value = yamlencode({
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name        = var.name
      namespace   = var.namespace
      annotations = var.annotations
      labels      = var.labels
    }
    spec = {
      ingressClassName = var.ingress_class_name
      rules            = local.rules
    }
  })
}