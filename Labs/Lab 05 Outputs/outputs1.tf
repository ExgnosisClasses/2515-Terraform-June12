output "resource_group_id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.lab5.id
}

output "resource_group_owner" {
  description = "The owner tag value of the resource group."
  value       = azurerm_resource_group.lab5.tags["owner"]
}

output "resource_group_name_uppercase" {
  description = "The uppercase version of the resource group name (computed)."
  value       = upper(azurerm_resource_group.lab5.name)
}

output "client_id" {
    description = "Outputs the existing client id."
  value = data.azurerm_client_config.current.client_id
}