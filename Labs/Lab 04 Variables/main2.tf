
# Lab 4 -  Variables

resource "azurerm_resource_group" "lab4" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = "test environment"
    owner       = "The wonder lama"
    purpose     = "demonstrate stuff"
  }
}
