terraform {}

variable "name" {
  type = string
}

variable "node_labels" {
  type    = map(string)
  default = {}
}

variable "node_taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "node_requirements" {
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = []
}

variable "node_class_ref_group" {
  type    = string
  default = "karpenter.k8s.aws"
}

variable "node_class_ref_kind" {
  type    = string
  default = "EC2NodeClass"
}

variable "node_class_ref_name" {
  type = string
}

variable "node_expires_after" {
  type    = string
  default = "Never"
}

variable "disruption_consolidation_policy" {
  type    = string
  default = "WhenEmpty"
}

variable "disruption_consolidate_after" {
  type    = string
  default = "1m"
}

output "manifest" {
  value = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = var.name
    }
    spec = {
      template = {
        metadata = {
          labels = var.node_labels
        }
        spec = {
          taints       = var.node_taints
          requirements = var.node_requirements
          nodeClassRef = {
            group = var.node_class_ref_group
            kind  = var.node_class_ref_kind
            name  = var.node_class_ref_name
          }
          expireAfter = var.node_expires_after
        }
      }
      disruption = {
        consolidationPolicy = var.disruption_consolidation_policy
        consolidateAfter    = var.disruption_consolidate_after
      }
    }
  })
}