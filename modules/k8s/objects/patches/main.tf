terraform {}

variable "patches" {
  type = list(object({
    op    = string
    path  = string
    value = optional(any)
  }))
}

output "manifest" {
  value = yamlencode(var.patches)
}