variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "lab-rg"
}

variable "location" {
  description = "The Azure location for the resources"
  type        = string
  default     = "eastus"
}

