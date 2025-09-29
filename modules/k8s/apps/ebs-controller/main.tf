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

variable "ebs_controller_helm_version" {
  type = string
}

variable "service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "storage_class_name" {
  type = string
}

variable "storage_class_type" {
  type    = string
  default = "gp3"
}

variable "storage_class_annotations" {
  type    = map(string)
  default = {}
}

locals {
  kustomization_file = "kustomization.yaml"
  storage_class_file = "storage-class.yaml"
  values_file        = "values.yaml"
}

module "storageclass" {
  source = "../../../../modules/k8s/objects/storageclass"

  name               = var.storage_class_name
  annotations        = var.storage_class_annotations
  storage_class_type = var.storage_class_type
}

resource "local_file" "storage_class" {
  filename = join("/", [var.path, local.storage_class_file])
  content  = module.storageclass.manifest
}

module "kustomization" {
  source = "../../../../modules/k8s/objects/kustomization"

  namespace = var.namespace
  helm_charts = [{
    name         = "aws-ebs-csi-driver"
    release_name = "ebs-controller"
    namespace    = var.namespace
    version      = var.ebs_controller_helm_version
    repo         = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
    values_file  = "./${local.values_file}"
  }]
  resources = []
}

resource "local_file" "kustomization" {
  filename = join("/", [var.path, local.kustomization_file])
  content  = module.kustomization.manifest
}

resource "local_file" "values" {
  filename = join("/", [var.path, local.values_file])
  content = yamlencode({
    controller = {
      serviceAccount = {
        annotations = var.service_account_annotations
      }
    }
  })
}