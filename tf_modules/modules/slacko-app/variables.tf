variable "vpc_id" {
  type = string
}

variable "subnet_cidr" {
  type = string
}
variable "name" {
  type = string
}
variable "tags" {
  type = map(string)
}
