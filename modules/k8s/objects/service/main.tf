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

variable "internal_traffic_policy" {
  type    = string
  default = "Cluster"
}

variable "ip_families" {
  type    = list(string)
  default = ["IPv4"]
}

variable "ip_family_policy" {
  type    = string
  default = "SingleStack"
}

variable "ports" {
  type = list(object({
    name        = string
    port        = number
    target_port = string
    protocol    = string
  }))
  default = []
}

variable "selector" {
  type    = map(string)
  default = {}
}

variable "type" {
  type    = string
  default = "NodePort"
}

output "manifest" {
  value = yamlencode({
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name        = var.name
      namespace   = var.namespace
      annotations = var.annotations
      labels      = var.labels
    }
    spec = {
      internalTrafficPolicy = var.internal_traffic_policy
      ipFamilies            = var.ip_families
      ipFamilyPolicy        = var.ip_family_policy
      ports = [for v in var.ports : {
        name       = v.name
        port       = v.port
        targetPort = v.target_port
        protocol   = v.protocol
      }]
      type     = var.type
      selector = var.selector
    }
  })
}