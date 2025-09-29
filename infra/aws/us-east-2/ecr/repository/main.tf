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

resource "aws_ecr_repository" "this" {
  name                 = var.repo-name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_name" {
  value = aws_ecr_repository.this.name
}

output "repository_arn" {
  value = aws_ecr_repository.this.arn
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}