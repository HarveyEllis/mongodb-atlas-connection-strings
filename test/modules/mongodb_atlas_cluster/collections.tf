//TODO: Put all these in a for_each loop with some config objects
resource "null_resource" "possums_collection_dev" {
  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
    mongosh "${mongodbatlas_cluster.atlas-cluster.connection_strings[0].standard_srv}" \
    --username ${mongodbatlas_database_user.db-user.username} \
    --password ${random_password.db-user-password.result} \
    --eval "db=db.getSiblingDB('marsupials-dev'); if(!db.getCollectionNames().includes('possums')) {db.createCollection('possums')}"
    EOT
  }
  depends_on = [mongodbatlas_cluster.atlas-cluster, mongodbatlas_database_user.db-user, mongodbatlas_project_ip_whitelist.project-whitelist-myip]
}

resource "null_resource" "numbats_collection_dev" {
  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
    mongosh "${mongodbatlas_cluster.atlas-cluster.connection_strings[0].standard_srv}" \
    --username ${mongodbatlas_database_user.db-user.username} \
    --password ${random_password.db-user-password.result} \
    --eval "db=db.getSiblingDB('marsupials-dev'); if(!db.getCollectionNames().includes('numbats')) {db.createCollection('numbats')}"
    EOT
  }
  depends_on = [mongodbatlas_cluster.atlas-cluster, mongodbatlas_database_user.db-user, mongodbatlas_project_ip_whitelist.project-whitelist-myip]
}

resource "null_resource" "numbats_collection_prod" {
  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
    mongosh "${mongodbatlas_cluster.atlas-cluster.connection_strings[0].standard_srv}" \
    --username ${mongodbatlas_database_user.db-user.username} \
    --password ${random_password.db-user-password.result} \
    --eval "db=db.getSiblingDB('marsupials-prod'); if(!db.getCollectionNames().includes('possums')) {db.createCollection('possums')}"
    EOT
  }
  depends_on = [mongodbatlas_cluster.atlas-cluster, mongodbatlas_database_user.db-user, mongodbatlas_project_ip_whitelist.project-whitelist-myip]
}

resource "null_resource" "possums_collection_prod" {
  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
    mongosh "${mongodbatlas_cluster.atlas-cluster.connection_strings[0].standard_srv}" \
    --username ${mongodbatlas_database_user.db-user.username} \
    --password ${random_password.db-user-password.result} \
    --eval "db=db.getSiblingDB('marsupials-prod'); if(!db.getCollectionNames().includes('numbats')) {db.createCollection('numbats')}"
    EOT
  }
  depends_on = [mongodbatlas_cluster.atlas-cluster, mongodbatlas_database_user.db-user, mongodbatlas_project_ip_whitelist.project-whitelist-myip]
}