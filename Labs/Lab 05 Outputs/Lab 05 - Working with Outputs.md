# Lab 4: Working with outputs

### Conceptualization

- Think of the root module you have been working with as a function that is called
- The variables defined in the `variables.tf` file are like a parameter list
- The `terraform.tfvars` file is like a list of arguments that supply the values to those parameters
- The `outputs.tf` file defines the return values that are returned to the calling module.

## Part 1: Setup

- For this lab, you can use the same files as the last lab.
- These are in the lab directory
- The only change is the addition of the `outputs.tf` file

```terraform
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

```

- Note that we can apply transformations to the outputs to return a computed version of the value, using string interpolation, for example.
- Upload the files making sure your subscription is properly entered in the `providers.tf` file.

## Run the code

- Your output should look like this:

```console
terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab5 will be created
  + resource "azurerm_resource_group" "lab5" {
      + id       = (known after apply)
      + location = "eastus2"
      + name     = "Lab5"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "The dev team"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + resource_group_id             = (known after apply)
  + resource_group_name_uppercase = "LAB5"
  + resource_group_owner          = "The dev team"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab5: Creating...
azurerm_resource_group.lab5: Creation complete after 10s [id=/subscriptions/f1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab5]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

resource_group_id = "/subscriptions/fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx2886b/resourceGroups/Lab5"
resource_group_name_uppercase = "LAB5"
resource_group_owner = "The dev team"
rod [ ~ ]$ 
```
- Notice the outputs and how the id value is available only after the resource is created


## Part 3: Tear down

- Run `terraform destroy` to tear down the configuration
- Notice that Terraform tells you the outputs will become null

```console
Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - resource_group_id             = "/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/Lab5" -> null
  - resource_group_name_uppercase = "LAB5" -> null
  - resource_group_owner          = "The dev team" -> null
```

## Part 4: Accessing data

- In this section, you will make changes to the files to access data in the Azure environment you didn't create

- First we have to make the data accessible so modify the `main.tf` file with the addition of the `data` directive
- This file is available as `main1.tf` in the lab directory


```terraform

data "azurerm_client_config" "current" {}

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
```

- Next, add the line to the `outputs.tf` to print out this value
- This is available as `outputs1.tf` in the lab folder

```terraform
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

```

- Run the new configuration and you should see something like this:

```console
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab5: Creating...
azurerm_resource_group.lab5: Still creating... [10s elapsed]
azurerm_resource_group.lab5: Creation complete after 10s [id=/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab5]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

client_id = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
resource_group_id = "/subscriptions/f1axxxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/Lab5"
resource_group_name_uppercase = "LAB5"
resource_group_owner = "The dev team"
```

## Teardown
- Run `terraform destroy` to clean up

## End lab