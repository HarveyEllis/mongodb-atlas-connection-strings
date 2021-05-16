# Create a project
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.atlas_org_id
  name = var.atlas_project_name
}

### Whitelisting ips
# Get IP Address - this may change so keep an eye on it!
data "http" "my_current_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Whitelist my current IP address
resource "mongodbatlas_project_ip_whitelist" "project-whitelist-myip" {
  count = var.whitelist_current_ip ? 1 : 0
  project_id = mongodbatlas_project.atlas-project.id
  ip_address = chomp(data.http.my_current_ip.body)
  comment    = "IP Address for home"
}

resource "mongodbatlas_cluster" "atlas-cluster" {
  project_id = mongodbatlas_project.atlas-project.id
  name = var.cluster_name
  num_shards = 1  
  replication_factor = 3
  provider_backup_enabled = true
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version = "4.2"
  
  provider_name = "GCP"
  disk_size_gb = 40
  provider_instance_size_name = var.cluster_instance_size_name
  provider_region_name = var.atlas_region
}

# Create a Database Password
resource "random_password" "db-user-password" {
  length = 16
  special = true
  override_special = "_%@"
}

# Create a Database User
resource "mongodbatlas_database_user" "db-user" {
  username = "db-admin"
  password = random_password.db-user-password.result
  project_id = mongodbatlas_project.atlas-project.id
  auth_database_name = "admin"  
  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}

locals {
  temp_pw = "d07Wrf1N6LDdLI_8"
}

output "connection_strings" {
  value = mongodbatlas_cluster.atlas-cluster.connection_strings[0].standard_srv
}