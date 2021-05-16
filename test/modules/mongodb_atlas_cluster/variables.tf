variable "atlas_org_id" {
  type        = string
  description = "Atlas organization id"
}

# Atlas Project Name
variable "atlas_project_name" {
  type        = string
  description = "Atlas project name"
}

variable "cluster_name" {
  type = string
  description = "The name to create the cluster with"
}

# Atlas Project environment
variable "environment" {
  type        = string
  description = "The environment to be built"
}

# Cluster instance size name 
variable "cluster_instance_size_name" {
  type        = string
  description = "Cluster instance size name"
  default     = "M0"
}

# Atlas region
variable "atlas_region" {
  type        = string
  description = "GCP region where resources will be created"
  default     = "europe-west1"
}

variable "whitelist_current_ip" {
  type = bool
  description = "Whether to whitelist the ip address of this machine or not"
  default = true
}

