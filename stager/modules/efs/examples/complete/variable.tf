################################################################################
# Input variables for the main.tf file
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

variable "region" {
  type    = string
  default = "us-east-1"
}
variable "namespace" {
  type    = string
  default = "Adex"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "attributes" {
  type    = list(string)
  default = []
}
