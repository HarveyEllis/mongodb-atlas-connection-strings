
# Nb: This module is implicitly getting the provider from provider-main.tf
module "mongodb_atlas_cluster" {
    source = "../../modules/mongodb_atlas_cluster/"
    
    atlas_org_id = var.atlas_org_id
    atlas_project_name = var.atlas_project_name
    cluster_name = var.cluster_name
    environment= var.environment
    cluster_instance_size_name = var.cluster_instance_size_name
    atlas_region = var.atlas_region
    whitelist_current_ip = true
    
}