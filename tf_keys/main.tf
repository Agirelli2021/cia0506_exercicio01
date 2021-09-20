variable "planos" {
  type = map
  default = {
    "small"  = "1xCPU-1GB"
    "medium" = "1xCPU-2GB"
    "large" = "2xCPU-4GB"
  }
}

output "chaves" {
value = keys(var.planos)
}

