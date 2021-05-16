# Define Terraform provider
terraform {
  required_version = ">= 0.14"

  required_providers {
    mongodbatlas = {
       source = "registry.terraform.io/mongodb/mongodbatlas"
       version = ">= 0.9.0"
    }
  }
}

# Define the MongoDB Atlas Provider
provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

