
# Lab 4 configuration - hard coded

resource "azurerm_resource_group" "lab4" {
  name     = "Lab4"
  location = "eastus"
  tags = {
      environment = "test environment"
      owner       = "The wonder lama"
      purpose     = "demonstrate stuff"
    }
}