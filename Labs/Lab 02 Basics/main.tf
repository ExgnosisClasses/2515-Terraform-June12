
# Lab 2 workflow

resource "azurerm_resource_group" "lab2" {
  name     = "Lab2"
  location = "eastus"
  tags = {
      environment = "test environment"
      owner       = "Zippy"
      purpose     = "demonstrate stuff"
    }
}