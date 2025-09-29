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

variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "private_dns_hostname_type_on_launch" {
  type    = string
  default = "ip-name"
}

variable "eni_id" {
  type = string
}

variable "subnet_tags" {
  type    = map(string)
  default = {}
}

variable "rtb_tags" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_subnet" "this" {
  vpc_id                              = var.vpc_id
  cidr_block                          = var.cidr_block
  availability_zone                   = var.availability_zone
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = var.private_dns_hostname_type_on_launch
  tags                                = merge({ Name = "${var.name}-private-${var.availability_zone}" }, merge(var.tags, var.subnet_tags))
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, var.rtb_tags)
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = var.eni_id
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

output "subnet_id" {
  value = aws_subnet.this.id
}

output "rtb_id" {
  value = aws_route_table.this.id
}