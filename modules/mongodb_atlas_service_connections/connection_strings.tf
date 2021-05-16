# this gets all the mongoatlas clusters in the project
data mongodbatlas_clusters list_project_clusters {
  project_id = var.project_id
}

# gets additional data 
data mongodbatlas_cluster project_clusters_details {
  for_each = toset(data.mongodbatlas_clusters.list_project_clusters.results[*].name)

  project_id = var.project_id
  name       = each.value
}

locals {
  
  
  service_config_as_map = {
    for svc in var.service_configuration : "${svc.serviceName}_${svc.mongoCluster}_${svc.mongoDatabase}" => svc
  }

  # produce the connection strings, relying on the values already there in other resources
  service_config_with_connections = {
    for key, svc in local.service_config_as_map : key => {
        serviceName = svc.serviceName
        mongoCluster = svc.mongoCluster
        mongoDatabase = svc.mongoDatabase
        mongoCollection = svc.mongoCollection
        roles = mongodbatlas_database_user.store-service-user[key].roles
        connections = {
          for role in mongodbatlas_database_user.store-service-user[key].roles : "${role.database_name}_${role.collection_name}" => 
            "mongodb+srv://${
            mongodbatlas_database_user.store-service-user[key].username}:${
            mongodbatlas_database_user.store-service-user[key].password}@${
            svc.mongoCluster}/${
            role.database_name}/${
            role.collection_name}"
        }
    }
  }

  #   # transform the service config into something that is easier to work with
  # temp_transformation = flatten([
  #   for svc in var.service_configuration :  [
  #     for col in svc.mongoCollection : {
  #       serviceName = svc.serviceName
  #       mongoCluster = svc.mongoCluster
  #       mongoDatabase = svc.mongoDatabase
  #       mongoCollection = col
  #     }
  #   ]
  # ])
  # all_service_connection_combinations = {
  #   for svc in local.temp_transformation : "${svc.serviceName}_${svc.mongoCluster}_${svc.mongoDatabase}_${svc.mongoCollection}" => svc
  # }
}
