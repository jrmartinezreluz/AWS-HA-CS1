output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}

output "asg_name" {
  value = module.ec2.asg_name
}

output "target_group_arn" {
  value = module.ec2.target_group_arn
}

output "rds_endpoint" {
  value     = module.rds.rds_endpoint
  sensitive = true
}
