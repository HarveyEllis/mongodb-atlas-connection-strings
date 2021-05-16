module "mongo_atlas_service_connections" {
  source = "../../../modules/mongodb_atlas_service_connections"
  
  project_id = var.project_id
  service_configuration = var.service_configuration
}

output test {
  value = module.mongo_atlas_service_connections.test
  sensitive = true
}
