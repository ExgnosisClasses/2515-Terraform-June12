
# Lab 3 state

resource "azurerm_resource_group" "lab3" {
  name     = "Lab3"
  location = "eastus"
  tags = {
      environment = "test environment"
      owner       = "Zippy"
      purpose     = "demonstrate stuff"
    }
}