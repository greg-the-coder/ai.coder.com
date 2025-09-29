terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "cluster_name" {
  type = string
}

variable "cluster_oidc_provider_arn" {
  type = string
}

variable "policy_name" {
  type    = string
  default = ""
}

variable "role_name" {
  type    = string
  default = ""
}

variable "namespace" {
  type = string
}

variable "name" {
  type    = string
  default = "fetch-and-store"
}

variable "image_repo" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "fetch_and_store_script_file_name" {
  type    = string
  default = "fetch-and-store.sh"
}

variable "tags" {
  type    = map(string)
  default = {}
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

locals {
  app_labels = {
    "app.kubernetes.io/name" : var.name
    "app.kubernetes.io/part-of" : var.name
  }
  policy_name = var.policy_name == "" ? "FetchAndStore-${data.aws_region.this.region}" : var.policy_name
  role_name   = var.role_name == "" ? "fetch-and-store-${data.aws_region.this.region}" : var.role_name
}

module "policy" {
  source      = "../../../security/policy"
  name        = local.policy_name
  path        = "/"
  description = "Fetch-and-Store Image Policy"
  policy_json = data.aws_iam_policy_document.this.json
}

module "oidc-role" {
  source       = "../../../security/role/access-entry"
  name         = local.role_name
  cluster_name = var.cluster_name
  policy_arns = {
    "FetchAndStore" = module.policy.policy_arn
  }
  cluster_policy_arns = {
    "AmazonEKSClusterAdminPolicy" = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
  }
  oidc_principals = {
    "${var.cluster_oidc_provider_arn}" = ["system:serviceaccount:*:*"]
  }
  tags = var.tags
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_role" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.app_labels
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["fetch-and-store"]
    verbs          = ["get", "create", "update", "patch"]
  }
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" : module.oidc-role.role_arn
    }
    labels = local.app_labels
  }
}

resource "kubernetes_role_binding" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.app_labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.this.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

resource "kubernetes_config_map" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.app_labels
  }
  data = {
    "${var.fetch_and_store_script_file_name}" = file("${path.module}/scripts/${var.fetch_and_store_script_file_name}")
  }
}

resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      labels    = local.app_labels
      name      = var.name
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    spec = {
      schedule                   = "0 0 * * 1"
      successfulJobsHistoryLimit = 0
      failedJobsHistoryLimit     = 1
      suspend                    = false
      timeZone                   = "America/Vancouver"
      concurrencyPolicy          = "Replace"
      jobTemplate = {
        metadata = {
          labels = local.app_labels
        }
        spec = {
          parallelism = 1
          template = {
            metadata = {
              labels = local.app_labels
            }
            spec = {
              serviceAccountName = kubernetes_service_account.this.metadata[0].name
              restartPolicy      = "OnFailure"
              initContainers = [{
                name            = "fetch"
                image           = "ghcr.io/coder/coder-preview:latest"
                imagePullPolicy = "IfNotPresent"
                command         = split(" ", "/bin/sh -c exit 0")
                }, {
                name            = "docker-sidecar"
                image           = "docker:dind"
                restartPolicy   = "Always"
                imagePullPolicy = "IfNotPresent"
                command         = split(" ", "dockerd -H tcp://127.0.0.1:2375")
                env = [{
                  name  = "DOCKER_HOST"
                  value = "localhost:2375"
                }]
                resources = {
                  limits = {
                    cpu               = "1"
                    ephemeral-storage = "10Gi"
                    memory            = "2Gi"
                  }
                  requests = {
                    ephemeral-storage = "5Gi"
                  }
                }
                securityContext = {
                  allowPrivilegeEscalation = true
                  privileged               = true
                  runAsUser                = 0
                }
              }]
              containers = [{
                name            = "store"
                image           = "${var.image_repo}:${var.image_tag}"
                imagePullPolicy = "IfNotPresent"
                command         = split(" ", "/bin/bash /tmp/${var.fetch_and_store_script_file_name}")
                resources = {
                  limits = {
                    cpu               = "2"
                    ephemeral-storage = "20Gi"
                    memory            = "9Gi"
                  }
                  requests = {
                    cpu               = "1"
                    ephemeral-storage = "10Gi"
                    memory            = "1Gi"
                  }
                }
                env = [{
                  name  = "DOCKER_HOST"
                  value = "localhost:2375"
                  }, {
                  name  = "AWS_ACCOUNT_ID"
                  value = data.aws_caller_identity.this.account_id
                  }, {
                  name  = "AWS_REGION"
                  value = data.aws_region.this.region
                }]
                volumeMounts = [{
                  name      = kubernetes_config_map.this.metadata[0].name
                  mountPath = "/tmp/${var.fetch_and_store_script_file_name}"
                  subPath   = var.fetch_and_store_script_file_name
                }]
              }]
              volumes = [{
                name = kubernetes_config_map.this.metadata[0].name
                configMap = {
                  name        = kubernetes_config_map.this.metadata[0].name
                  defaultMode = 511 # Equivalent to 777
                  items = [{
                    key  = var.fetch_and_store_script_file_name
                    path = var.fetch_and_store_script_file_name
                  }]
                }
              }]
            }
          }


        }
      }
    }
  }
}

# resource "kubernetes_cron_job_v1" "this" {
#     metadata {
#         name = var.name
#         namespace = kubernetes_namespace.this.metadata[0].name
#         labels = local.app_labels
#     }
#     spec {
#         timezone = "America/Vancouver"
#         successful_jobs_history_limit = 0
#         failed_jobs_history_limit = 1
#         concurrency_policy = "Replace"
#         schedule = "0 0 * * 1"
#         job_template {
#             metadata {
#                 labels = local.app_labels
#             }
#             spec {
#                 parallelism = 1
#                 template {
#                     metadata {
#                         labels = local.app_labels
#                     }
#                     spec {
#                         service_account_name = kubernetes_service_account.this.metadata[0].name
#                         restart_policy = "OnFailure"
#                         init_container {
#                             name = "fetch"
#                             image = "ghcr.io/coder/coder-preview:latest"
#                             image_pull_policy = "IfNotPresent"
#                             command = split(" ",  "/bin/sh -c exit 0")
#                         }
#                         init_container {
#                             name = "docker-sidecar"
#                             image = "docker:dind"
#                             # restart_policy = "Always"
#                             image_pull_policy = "IfNotPresent"
#                             command = split(" ",  "dockerd -H tcp://127.0.0.1:2375")
#                             env {
#                                 name = "DOCKER_HOST"
#                                 value = "localhost:2375"
#                             }
#                             resources {
#                                 requests = {
#                                     ephemeral-storage = "5Gi"
#                                 }
#                                 limits = {
#                                     ephemeral-storage = "10Gi"
#                                     memory = "2048Mi"
#                                     cpu = "1000m"
#                                 }
#                             }
#                             security_context {
#                                 privileged = true
#                                 run_as_user = 0
#                             }
#                         }
#                         container {
#                             name  = "store"
#                             image = "${var.image_repo}:${var.image_tag}"
#                             image_pull_policy = "IfNotPresent"
#                             command = split(" ", "/bin/sh /tmp/${var.fetch_and_store_script_file_name}")
#                             env {
#                                 name = "DOCKER_HOST"
#                                 value = "localhost:2375"
#                             }
#                             env {
#                                 name = "AWS_ACCOUNT_ID"
#                                 value = data.aws_caller_identity.this.account_id
#                             }
#                             env {
#                                 name = "AWS_REGION"
#                                 value = data.aws_region.this.region
#                             }
#                             volume_mount {
#                                 name = kubernetes_config_map.this.metadata[0].name
#                                 mount_path = "/tmp/${var.fetch_and_store_script_file_name}"
#                                 sub_path = var.fetch_and_store_script_file_name
#                             }
#                             resources {
#                                 requests = {
#                                     ephemeral-storage = "10Gi"
#                                     memory = "1024Mi"
#                                     cpu = "1000m"
#                                 }
#                                 limits = {
#                                     ephemeral-storage = "20Gi"
#                                     memory = "9216Mi"
#                                     cpu = "2000m"
#                                 }
#                             }
#                         }
#                         volume {
#                             name = kubernetes_config_map.this.metadata[0].name
#                             config_map {
#                                 name = kubernetes_config_map.this.metadata[0].name
#                                 default_mode = "0777"
#                                 items {
#                                     key = var.fetch_and_store_script_file_name
#                                     path = var.fetch_and_store_script_file_name
#                                 }
#                             }
#                         }
#                     }
#                 }
#             }
#         }
#     }
# }