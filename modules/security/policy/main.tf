terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "name" {
  type = string
}

variable "path" {
  type    = string
  default = "/"
}

variable "description" {
  type    = string
  default = ""
}

variable "policy_json" {
  type = string
}

resource "aws_iam_policy" "this" {
  name_prefix = "${var.name}-"
  path        = var.path
  policy      = var.policy_json
  description = var.description
}

output "policy_id" {
  value = aws_iam_policy.this.id
}

output "policy_arn" {
  value = aws_iam_policy.this.arn
}