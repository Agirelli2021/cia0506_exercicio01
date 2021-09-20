provider "aws" {
}


variable "usernames" {
  type = list

  default = [
    "neo",
    "leonardo",
  ]
}

resource "aws_iam_user" "names" {
  count = length(var.usernames)
  name  = var.usernames[count.index]
}
