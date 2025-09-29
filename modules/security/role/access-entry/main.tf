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

variable "cluster_name" {
  type = string
}

variable "path" {
  type    = string
  default = "/"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "oidc_principals" {
  type    = map(list(string))
  default = {}
}

variable "policy_arns" {
  type    = map(string)
  default = {}
}

variable "cluster_create_access_entry" {
  type    = bool
  default = false
}

variable "cluster_policy_arns" {
  type    = map(string)
  default = {}
}

variable "cluster_access_type" {
  type    = string
  default = "STANDARD"
}

data "aws_iam_policy_document" "sts" {
  dynamic "statement" {
    for_each = var.oidc_principals
    content {
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type        = "Federated"
        identifiers = [statement.key]
      }
      condition {
        test     = "StringLike"
        variable = "${join("/", slice(split("/", statement.key), 1, length(split("/", statement.key))))}:sub"
        values   = statement.value
      }
      condition {
        test     = "StringEquals"
        variable = "${join("/", slice(split("/", statement.key), 1, length(split("/", statement.key))))}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = var.policy_arns
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role" "this" {
  name_prefix        = "${var.name}-"
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.sts.json
  tags               = var.tags
}

resource "aws_eks_access_entry" "this" {

  count = var.cluster_create_access_entry ? 1 : 0

  principal_arn = aws_iam_role.this.arn
  cluster_name  = var.cluster_name
  type          = var.cluster_access_type
}

resource "aws_eks_access_policy_association" "attach" {

  depends_on = [aws_eks_access_entry.this[0]]
  for_each   = var.cluster_create_access_entry ? var.cluster_policy_arns : {}

  cluster_name  = var.cluster_name
  policy_arn    = each.value
  principal_arn = aws_iam_role.this.arn

  access_scope {
    type = "cluster"
  }
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "access_entry_arn" {
  value = try(aws_eks_access_entry.this[0].access_entry_arn, "SET CREATE_ACCESS_ENTRY TO TRUE")
}