

variable "resource_tags" {
    type = map(string)
    default = {}
}

locals {
  required_tags = {
      "project" = "impacta",
      "environment" = "prod"
  }
  tags = merge(var.resource_tags, local.required_tags)
}

output "tags" {
  value = local.tags
}

