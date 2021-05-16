# Atlas Project Id
variable "project_id" {
  type        = string
  description = "Atlas project id to be used for creating the database users in"
}

variable "service_configuration" {
    type = list(object({
      serviceName = string
      mongoCluster    = string
      mongoDatabase   = string
      mongoCollection = list(string)
    }))
}