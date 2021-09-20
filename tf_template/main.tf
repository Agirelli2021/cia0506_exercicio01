variable "curso" {
}

variable "pacotes" {
 default = ["docker","vim"]
}


data "template_file" "user_data" {
    template = file("user_data.sh")
    vars = {
          curso = var.curso
          pacotes = join(" ",var.pacotes)

    }
}

output "user_data" {
    value = data.template_file.user_data.rendered
}
