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