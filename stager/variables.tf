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
  description = "Region be used for all the resources"
  type        = string
  default     = "us-east-1"
}

variable "use_custom_vpc" {
  description = "Define if you want to use custom vpc"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public Subnet IDs"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR Block of private subnet"
  type        = list(string)
}
