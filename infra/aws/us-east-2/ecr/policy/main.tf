terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "repo-name" {
  type = string
}

variable "iam_policy_statements" {
  type    = any
  default = []
}

data "aws_iam_policy_document" "ecr_access_policy" {
  version = "2012-10-17"
  dynamic "statement" {
    for_each = var.iam_policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = var.repo-name
  policy     = data.aws_iam_policy_document.ecr_access_policy.json
}