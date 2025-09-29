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

variable "time_zone" {
  type    = string
  default = "America/Vancouver"
}

variable "successful_job_history_limit" {
  type    = number
  default = 1
}

variable "failed_job_history_limit" {
  type    = number
  default = 1
}

variable "concurrency_policy" {
  type    = string
  default = "Replace"
}

variable "schedule" {
  type = string
}

variable "parallelism" {
  type    = number
  default = 1
}

variable "service_account_name" {
  type    = string
  default = ""
}

variable "restart_policy" {
  type    = string
  default = "OnFailure"
}

variable "containers" {
  type = list(object({
    name  = string
    image = string
    ports = list(object({
      name           = string
      container_port = number
      protocol       = string
    }))
    env = optional(map(string), {})
    env_secret = optional(map(object({
      key  = string
      name = optional(string)
    })), {})
    resources = object({
      requests = map(string)
      limits   = map(string)
    })
    command = optional(list(string), [])
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
      read_only  = optional(bool, false)
      sub_path   = optional(string, "")
    })), [])
  }))
  default = []
}

variable "volumes_from_secrets" {
  type    = list(string)
  default = []
}

variable "volumes_from_config_map" {
  type    = list(string)
  default = []
}

output "manifest" {
  value = yamlencode({
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name        = var.name
      namespace   = var.namespace
      labels      = var.labels
      annotations = var.annotations
    }
    spec = {
      timeZone                   = var.time_zone
      successfulJobsHistoryLimit = var.successful_job_history_limit
      failedJobsHistoryLimit     = var.failed_job_history_limit
      concurrencyPolicy          = var.concurrency_policy
      schedule                   = var.schedule
      jobTemplate = {
        spec = {
          parallelism = var.parallelism
          template = {
            spec = {
              serviceAccountName = var.service_account_name
              restartPolicy      = var.restart_policy
              containers = [
                for c in var.containers : {
                  name  = c.name
                  image = c.image
                  ports = [for v in c.ports : {
                    name          = v.name
                    containerPort = v.container_port
                    protocol      = v.protocol
                  }]
                  env = concat([for k, v in c.env : {
                    name  = k
                    value = v
                    }], [for k, v in c.env_secret : {
                    name = k
                    valueFrom = {
                      secretKeyRef = {
                        name = v.name
                        key  = v.key
                      }
                    }
                  }])
                  resources = c.resources
                  command   = c.command
                  volumeMounts = [
                    for m in c.volume_mounts : {
                      name      = m.name
                      mountPath = m.mount_path
                      readOnly  = m.read_only
                      subPath   = m.sub_path
                    }
                  ]
                }
              ]
              volumes = concat([
                for v in var.volumes_from_config_map : {
                  name      = v
                  configMap = { name = v }
                }], [
                for v in var.volumes_from_secrets : {
                  name   = v
                  secret = { secretName = v }
                }
              ])
            }
          }
        }
      }
    }
  })
}