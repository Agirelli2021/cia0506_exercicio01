data "aws_ami" "slacko-app" {
  most_recent = true
  owners = ["amazon"]

  filter {
     name = "name"
     values = ["Amazon*"]
  }

  filter {
     name = "architecture"
     values = ["x86_64"] 
  }
}

data "aws_subnet" "subnet_public" {
    cidr_block = var.subnet_cidr
}

# gerando a chave com o arquivo slacko.pub executando o comando no diretorio slacko-app
# EX: vagrant@iaac-station:/vagrant/slacko-app$ ssh-keygen -C slacko -f slacko
# sera gerado um arquivo slacko.pub, comandar um cat no arquivo e colar no campo public_key abaixo
# EX: vagrant@iaac-station:/vagrant/slacko-app$ cat slacko.pub


resource "aws_key_pair" "slacko-sshkey" {
  key_name = "slacko-app-key"
  #Colar todo conteudo entre a chaves do slacko.pub
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC16nNff3FrXg06XvGH9RfL+fZK9FeoLoSyFKu6MkS/mCZ6GV9Q/Nc135HSy+MB+w9YdGJKVCLkpMbK0iAp7DMlaU8AVrB3eX0XLNmFVzMn7RNM5EbNvjaZdBCgzhoOqOojrozLfwe3nYgVYMMvPO5wrQuw6gACGiNXxGTlvAl2GTLY4+Qk0fhRiNpZMDWj+FjAa137N4RSPt9dhBUe+XcVlsV5YyWQQIHrd+vmwKktQGjWhGcSnAfKH6MtxqepNG/Rf3ZC3tcLTm8Uw1zl2zAw9XZT+rmeBiQF25JR58RCIQ8eHnVrIfmgjF8auXaFTJEoQckNUiYdZoXfwFgR27gI+Ag0QrpsrAbcwN4NpFlLEQDqt7GPWbFtUUfVtgdI3594Wt6k+7Py0X+FkyfjZFdE34zYiz/n0mdk4F7X7O5fuXSbHy/wiQf3cgwv8Si3OIv8VXNcS629rXTkakD9sQoiIROHSYO8zBwKI6t1Wel1dPUTkI5VUfYjCcaM1vPvpXM= slacko"

}


resource "aws_instance" "slacko-app" {
  ami = data.aws_ami.slacko-app.id
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.subnet_public.id
  associate_public_ip_address = true

  #mudei aqui
  tags = merge(var.tags,{ "Name" = format("%s-slacko-app", var.name)},)
  

  key_name = aws_key_pair.slacko-sshkey.id
  user_data = file("${path.module}/files/ec2.sh")

}

resource "aws_instance" "mongodb" {
  ami = data.aws_ami.slacko-app.id
  instance_type = "t2.small"
  subnet_id = data.aws_subnet.subnet_public.id
  #mudei aqui 
  tags = merge(var.tags,{ "Name" = format("%s-mongodb", var.name)},)
   
   

   key_name = aws_key_pair.slacko-sshkey.id
   # Arquivo de Bootstrap
   user_data = file("${path.module}/files/mongodb.sh")


}

resource "aws_security_group" "allow-slacko" {
    name = "allow_ssh_http"
    description = "allow ssh and http port"
    # entrar na AWS e em VPC na segunda coluna tem a VPC ID, colar no campo abaixo
    vpc_id = var.vpc_id

    ingress = [
        {
        description = "allow SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self      = true
        prefix_list_ids = null 
        security_groups = null
    }, 
        {
        description = "allow SSH"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self      = true
        prefix_list_ids = null 
        security_groups = null
    }
    ]

    egress = [
        {
        description = "allow SSH"
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self      = true
        prefix_list_ids = null 
        security_groups = null
        }
    ]

    tags = {
        Name = "allow_ssh_http"
    }
}

resource "aws_security_group" "allow-mongodb" {
    name = "allow_mongodb"
    description = "allow Mongodb"
    # entrar na AWS e em VPC na segunda coluna tem a VPC ID, colar no campo abaixo
    vpc_id = var.vpc_id

    ingress = [
        {
        description = "allow mongodb"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self      = true
        prefix_list_ids = null 
        security_groups = null
        }
    ]



    egress = [
        {
        description = "allow all"
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self      = true
        prefix_list_ids = null 
        security_groups = null
        }
    ]
    #mudei aqui
    tags = merge(var.tags,{ "Name" = format("%s-allowmongodb", var.name)},)
    
}

resource "aws_network_interface_sg_attachment" "mongodb-sg" {
    security_group_id = aws_security_group.allow-mongodb.id
    network_interface_id = aws_instance.mongodb.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "slacko-sg" {
    security_group_id = aws_security_group.allow-slacko.id
    network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}


resource "aws_route53_zone" "slack_zone"{
    name = "iaac0506.com.br"

    vpc {
        # entrar na AWS e em VPC na segunda coluna tem a VPC ID, colar no campo abaixo
        vpc_id = var.vpc_id
    }
    #MUDEI AQUI
    tags = merge(var.tags,{ "Name" = format("%s-SLACK-ZONE", var.name)},)
}

resource "aws_route53_record" "mongodb"{
    zone_id = aws_route53_zone.slack_zone.id
    name = "mongodb.iaac0506.com.br"
    type = "A"
    ttl = "300"
    records = [aws_instance.mongodb.private_ip]
}
