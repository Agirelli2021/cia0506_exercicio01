module "slackoapp" {
  source = "./modules/slacko-app"
  vpc_id = "vpc-0405b419d771694d8"
  subnet_cidr = "10.0.102.0/24"
   
   name = "Anderson"
  tags = {
    env = "prod"
    disciplina = "CIA0506" 
     }

}

output "slackip" {
    value = module.slackoapp.slacko-app
}

output "mongodb" {
    value =module.slackoapp.slacko-mongodb
}