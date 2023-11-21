################################################################################
# Input variables for the main.tf file
################################################################################

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
