terraform {}

variable "namespace" {
  type = string
}

variable "resources" {
  type    = list(string)
  default = []
}

variable "config_map_generator" {
  type = list(object({
    name      = string
    namespace = string
    behavior  = optional(string, "create")
    literals  = optional(list(string), [])
    files     = optional(list(string), [])
    envs      = optional(list(string), [])
    options = optional(object({
      disable_name_suffix_hash = optional(bool, true)
      }), {
      disable_name_suffix_hash = true
    })
  }))
  default = []
}

variable "secret_generator" {
  type = list(object({
    name      = string
    namespace = string
    behavior  = optional(string, "create")
    literals  = optional(list(string), [])
    files     = optional(list(string), [])
    envs      = optional(list(string), [])
    options = optional(object({
      disable_name_suffix_hash = optional(bool, true)
      }), {
      disable_name_suffix_hash = true
    })
  }))
  default = []
}

variable "helm_charts" {
  type = list(object({
    name          = string
    release_name  = string
    version       = string
    repo          = string
    namespace     = string
    include_crds  = optional(bool, false)
    values_file   = optional(string, "")
    values_inline = optional(map(any), {})
  }))
  default = []
}

variable "patches" {
  type = list(object({
    path = optional(string, "")
    patch = optional(list(object({
      op    = string
      path  = string
      value = optional(any)
    })), [])
    target = object({
      group   = optional(string, "")
      version = string
      kind    = string
      name    = string
    })
  }))
  default = []
}

locals {
  patches = [for v in var.patches : {
    path   = v.path
    target = v.target
    patch  = jsonencode(v.patch) # replace(jsonencode(v.patch), "\"", "\\\"")
  }]
}

locals {
  secret_generator = [for v in var.secret_generator : {
    name      = v.name
    namespace = v.namespace
    behavior  = v.behavior
    literals  = v.literals
    files     = v.files
    envs      = v.envs
    options = {
      disableNameSuffixHash = v.options.disable_name_suffix_hash
    }
  }]
  config_map_generator = [for v in var.config_map_generator : {
    name      = v.name
    namespace = v.namespace
    behavior  = v.behavior
    literals  = v.literals
    files     = v.files
    envs      = v.envs
    options = {
      disableNameSuffixHash = v.options.disable_name_suffix_hash
    }
  }]
  helm_charts = [for v in var.helm_charts : {
    name         = v.name
    releaseName  = v.release_name
    namespace    = v.namespace
    version      = v.version
    repo         = v.repo
    includeCRDs  = v.include_crds
    valuesFile   = v.values_file
    valuesInline = v.values_inline
  }]
}

output "manifest" {
  value = yamlencode({
    apiVersion         = "kustomize.config.k8s.io/v1beta1"
    kind               = "Kustomization"
    namespace          = var.namespace
    configMapGenerator = local.config_map_generator
    secretGenerator    = local.secret_generator
    helmCharts         = local.helm_charts
    resources          = var.resources
    patches            = local.patches
  })
}