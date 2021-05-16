variable "atlas_public_key" {
  type        = string
  description = "MongoDB Atlas Public Key"
  sensitive   = true
}

variable "atlas_private_key" {
  type        = string
  description = "MongoDB Atlas Private Key"
  sensitive   = true
}