#General Variables
variable "name_prefix" {
  type = string
}
variable "name_postfix" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "create_bucket" {
  type = bool
}

variable "destroy_infrastructure" {
  description = "Set to true to destroy all resources. Do not use in production."
  type        = bool
  default     = false
}