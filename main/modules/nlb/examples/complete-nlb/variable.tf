################################################################################
# Input variables
################################################################################
variable "environment" {
  description = "Working application environment eg: dev, stg, prd"
  type        = string
  default     = ""
}

variable "application" {
  description = "Name of the application"
  type        = string
  default     = ""
}

variable "owner" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "attributes" {
  description = "Attribute is the name of the attribute for the terratest"
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "The domain name for which the certificate should be issued"
  type        = string
  default     = "aawajai.com"
}

variable "public_dedicated_network_acl" {
  description = "condition for the creation of dedicated network access to the application"
  type        = bool
  default     = true
}

variable "private_dedicated_network_acl" {
  description = "condition for the creation of dedicated network access"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "condition for the deletion of the load balancers"
  type        = bool
  default     = true
}
