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

variable "cluster_name" {
  type = string
}

variable "karpenter_helm_version" {
  type = string
}

variable "karpenter_queue_name" {
  type = string
}

variable "resources" {
  type    = list(string)
  default = []
}

variable "karpenter_resource_request" {
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "250m"
    memory = "512Mi"
  }
}

variable "karpenter_resource_limit" {
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "500m"
    memory = "1Gi"
  }
}

variable "karpenter_controller_annotations" {
  type    = map(string)
  default = {}
}

variable "karpenter_replicas" {
  type    = number
  default = 0
}

variable "cluster_asg_node_labels" {
  type    = map(string)
  default = {}
}

variable "ec2nodeclass_configs" {
  type = list(object({
    name                 = string
    node_role_name       = string
    ami_alias            = optional(string, "al2023@latest")
    subnet_selector_tags = map(string)
    sg_selector_tags     = map(string)
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = object({
        volume_size           = string
        volume_type           = string
        encrypted             = optional(bool, false)
        delete_on_termination = optional(bool, true)
      })
    })), [])
  }))
}

variable "nodepool_configs" {
  type = list(object({
    name        = string
    node_labels = map(string)
    node_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    node_requirements = optional(list(object({
      key      = string
      operator = string
      values   = list(string)
    })), [])
    node_class_ref_name             = string
    node_expires_after              = optional(string, "Never")
    disruption_consolidation_policy = optional(string, "WhenEmpty")
    disruption_consolidate_after    = optional(string, "1m")
  }))
}

locals {
  values_file = "values.yaml"
}

module "namespace" {
  source = "../../objects/namespace"
  name   = var.namespace
}

resource "local_file" "namespace" {
  filename = "${var.path}/namespace.yaml"
  content  = module.namespace.manifest
}

module "kustomization" {
  source    = "../../objects/kustomization"
  namespace = var.namespace
  helm_charts = [{
    name         = "karpenter"
    release_name = "karpenter"
    repo         = "oci://public.ecr.aws/karpenter"
    namespace    = var.namespace
    include_crds = true
    version      = var.karpenter_helm_version
    values_file  = "./${local.values_file}"
  }]
  resources = concat(["namespace.yaml"], [
    for v in var.ec2nodeclass_configs : "${v.name}.yaml"
    ], [
    for v in var.nodepool_configs : "${v.name}.yaml"
  ], var.resources)
}

resource "local_file" "kustomization" {
  filename = "${var.path}/kustomization.yaml"
  content  = module.kustomization.manifest
}

module "ec2nodeclass" {
  count                 = length(var.ec2nodeclass_configs)
  source                = "../../objects/ec2nodeclass"
  name                  = var.ec2nodeclass_configs[count.index].name
  node_role_name        = var.ec2nodeclass_configs[count.index].node_role_name
  ami_alias             = var.ec2nodeclass_configs[count.index].ami_alias
  subnet_selector_tags  = var.ec2nodeclass_configs[count.index].subnet_selector_tags
  sg_selector_tags      = var.ec2nodeclass_configs[count.index].sg_selector_tags
  block_device_mappings = var.ec2nodeclass_configs[count.index].block_device_mappings
}

resource "local_file" "ec2nodeclass" {
  count    = length(var.ec2nodeclass_configs)
  filename = "${var.path}/${var.ec2nodeclass_configs[count.index].name}.yaml"
  content  = module.ec2nodeclass[count.index].manifest
}

module "nodepool" {
  count                           = length(var.nodepool_configs)
  source                          = "../../objects/nodepool"
  name                            = var.nodepool_configs[count.index].name
  node_labels                     = var.nodepool_configs[count.index].node_labels
  node_taints                     = var.nodepool_configs[count.index].node_taints
  node_requirements               = var.nodepool_configs[count.index].node_requirements
  node_class_ref_name             = var.nodepool_configs[count.index].node_class_ref_name
  node_expires_after              = var.nodepool_configs[count.index].node_expires_after
  disruption_consolidation_policy = var.nodepool_configs[count.index].disruption_consolidation_policy
  disruption_consolidate_after    = var.nodepool_configs[count.index].disruption_consolidate_after
}

resource "local_file" "nodepool" {
  count    = length(var.nodepool_configs)
  filename = "${var.path}/${var.nodepool_configs[count.index].name}.yaml"
  content  = module.nodepool[count.index].manifest
}

resource "local_file" "values" {
  filename = join("/", [var.path, local.values_file])
  content = yamlencode({
    settings = {
      clusterName       = var.cluster_name
      interruptionQueue = var.karpenter_queue_name
      featureGates = {
        spotToSpotConsolidation = "true"
      }
    }
    serviceAccount = {
      annotations = var.karpenter_controller_annotations
    }
    controller = {
      resources = {
        requests = var.karpenter_resource_request
        limits   = var.karpenter_resource_limit
      }
    }
    nodeSelector = var.cluster_asg_node_labels
    replicas     = var.karpenter_replicas
    dnsPolicy    = "ClusterFirst"
  })
}