output "cluster_name" {
  value = module.web.cluster_name
}

output "alb_dns_name" {
  value = module.web.alb_dns_name
}

output "ecr_repository_url" {
  value = module.web.ecr_repository_url
}