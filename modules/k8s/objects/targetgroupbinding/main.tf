terraform {}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "resources" {
  type    = list(string)
  default = []
}

variable "service_name" {
  type = string
}

variable "service_port" {
  type = number
}

variable "target_group_arn" {
  type = string
}


output "manifest" {
  value = yamlencode({
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      serviceRef = {
        name = var.service_name
        port = var.service_port
      }
      targetGroupARN = var.target_group_arn
    }
  })
}