
# Lab 3 state - modification 1

resource "azurerm_resource_group" "lab3" {
  name     = "Lab3"
  location = "eastus"
  tags = {
      environment = "test environment"
      owner       = "The wonder lama"
      purpose     = "demonstrate stuff"
    }
}