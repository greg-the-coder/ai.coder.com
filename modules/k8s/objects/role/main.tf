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

variable "rules" {
  type = list(object({
    api_groups     = optional(list(string), [""])
    resources      = optional(list(string), [""])
    resource_names = optional(list(string), [""])
    verbs          = optional(list(string), [""])
  }))
  default = []
}

output "manifest" {
  value = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "Role"
    metadata = {
      name        = var.name
      namespace   = var.namespace
      labels      = var.labels
      annotations = var.annotations
    }
    rules = [for v in var.rules : {
      apiGroups     = v.api_groups
      resources     = v.resources
      resourceNames = v.resource_names
      verbs         = v.verbs
    }]
  })
}