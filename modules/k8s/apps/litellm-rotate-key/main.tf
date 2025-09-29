terraform {}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "role_labels" {
  type    = map(string)
  default = {}
}

variable "role_annotations" {
  type    = map(string)
  default = {}
}

variable "service_account_labels" {
  type    = map(string)
  default = {}
}

variable "role_binding_labels" {
  type    = map(string)
  default = {}
}

variable "role_binding_annotations" {
  type    = map(string)
  default = {}
}

variable "service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "litellm_deployment_name" {
  type = string
}

variable "litellm_secret_key_name" {
  type = string
}

module "role" {
  source = "../../objects/role"

  name        = var.name
  namespace   = var.namespace
  labels      = var.role_labels
  annotations = var.role_annotations
  rules = [{
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = [var.litellm_secret_key_name]
    verbs          = ["get", "create", "update", "patch"]
    }, {
    api_groups     = ["apps", "extensions"]
    resources      = ["deployments"]
    resource_names = [var.litellm_deployment_name]
    verbs          = ["get", "patch"]
  }]
}

module "serviceaccount" {
  source = "../../objects/serviceaccount"

  name        = var.name
  namespace   = var.namespace
  labels      = var.service_account_labels
  annotations = var.service_account_annotations
}

module "rolebinding" {
  source = "../../objects/rolebinding"

  name        = var.name
  namespace   = var.namespace
  labels      = var.role_binding_labels
  annotations = var.role_binding_annotations
  role_ref = {
    name = var.name
  }
  subjects = [{
    name = var.name
  }]
}

module "kustomization" {
  source = "../../objects/cronjob"
}

module "cronjob" {
  source = "../../objects/cronjob"
}