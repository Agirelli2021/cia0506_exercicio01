provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "amazon2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

output image_id { 
   value = data.aws_ami.amazon2.id
   sensitive = false
}
