terraform {}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "private_key_secret_ref" {
  type = string
}

variable "acme_server" {
  type    = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "solvers" {
  type = list(map(object({
    cloudflare = optional(object({
      email = string
      api_token_secret_ref = object({
        name = string
        key  = string
      })
    }))
  })))
  default = []
}

locals {
  solvers = [for v in var.solvers : {
    cloudflare = try({
      email                = v.cloudflare.email
      api_token_secret_ref = v.cloudflare.api_token_secret_ref
    }, {})
  }]
}

output "manifest" {
  value = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      acme = {
        privateKeySecretRef = {
          name = var.private_key_secret_ref
        }
        server  = var.acme_server
        solvers = local.solvers
      }
    }
  })
}