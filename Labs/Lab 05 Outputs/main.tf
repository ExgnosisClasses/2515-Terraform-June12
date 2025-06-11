
# Lab 5 -  Outputs



locals {
  resource_owner = "The dev team"
}

resource "azurerm_resource_group" "lab5" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = "test environment"
    owner       = local.resource_owner
    purpose     = "demonstrate stuff"
  }
}
