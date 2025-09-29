terraform {}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "role_ref" {
  type = object({
    api_group = optional(string, "rbac.authorization.k8s.io")
    kind      = optional(string, "Role")
    name      = string
  })
}

variable "subjects" {
  type = list(object({
    kind      = optional(string, "ServiceAccount")
    name      = string
    namespace = optional(string, "")
  }))
  default = []
}

output "manifest" {
  value = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "RoleBinding"
    metadata = {
      name        = var.name
      namespace   = var.namespace
      labels      = var.labels
      annotations = var.annotations
    }
    roleRef = {
      apiGroup = var.role_ref.api_group
      kind     = var.role_ref.kind
      name     = var.role_ref.name
    }
    subjects = [for v in var.subjects : {
      kind      = v.kind
      name      = v.name
      namespace = v.namespace == "" ? var.namespace : v.namespace
    }]
  })
}