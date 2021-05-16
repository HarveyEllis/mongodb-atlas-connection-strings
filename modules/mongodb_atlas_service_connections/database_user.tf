resource "random_password" "service-password" {
  for_each = local.service_config_as_map
  
  length = 16
  special = true
  override_special = "_%@"
}

resource mongodbatlas_database_user store-service-user {
    for_each = local.service_config_as_map
    auth_database_name = "admin"

    project_id = var.project_id

  # create a username for the service (e.g. the service name)
  username           = each.value.serviceName
  # create a password for the service 
  password           = random_password.service-password[each.key].result
  # Create the right role (read only permissions) for this user and service
  dynamic roles {
    for_each = each.value.mongoCollection[*]
    content {
      role_name       = "read"
      database_name   = each.value.mongoDatabase
      collection_name = roles.value
    }
  }
}