terraform {}

variable "name" {
  type = string
}

output "manifest" {
  value = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.name
    }
  })
}