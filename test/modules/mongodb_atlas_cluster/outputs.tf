output "base_connection_string" {
  value = mongodbatlas_cluster.atlas-cluster.srv_address 
}

output "project_id" {
    value = mongodbatlas_project.atlas-project.id
}