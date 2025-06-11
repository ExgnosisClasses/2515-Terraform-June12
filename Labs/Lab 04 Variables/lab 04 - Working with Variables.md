# Lab 4: Working with variables

For this lab, we will 


## Part 1: Deploy a resource

### Hardcoded

Just like you did in the previous labs
- Delete any previous `main.tf` file in your cloud shell
- Upload the `main1.tf` file from the lab 4 directory.
- Use the same `providers.tf` file from before

```terraform
## Lab 4 configuration - hard coded

resource "azurerm_resource_group" "lab4" {
  name     = "Lab4"
  location = "eastus"
  tags = {
      environment = "test environment"
      owner       = "The wonder lama"
      purpose     = "demonstrate stuff"
    }
}
```


- Just like you did before, use `terraform apply` to create the resource'

```console
 terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab3 will be created
  + resource "azurerm_resource_group" "lab4" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Lab4"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "Zippy"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab4: Creating...
azurerm_resource_group.lab4: Creation complete after 10s [id=/subscriptions/f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3]
```

## Part 2: Add a variables file

- Upload the file `variables.tf` from the lab folder
- The file looks like this

```terraform
variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "Lab4"
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created."
  type        = string
  default     = "eastus"
}
```

- Notice that default values have been provided

- Modify the main file to use the variables.
- This is shown in file `main2.tf`
- Delete the `main1.tf` file
- upload the `main2.tf` file

```terraform
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
```

- Run `terraform apply` to confirm the resource is created

```console
 terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab4 will be created
  + resource "azurerm_resource_group" "lab4" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Lab4"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "The wonder lama"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab4: Creating...
azurerm_resource_group.lab4: Creation complete after 10s [id=/subscriptions/f1xxxxxxxxxxxxxxxxxxxxxxxx6364d2886b/resourceGroups/Lab4]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

- Now tear down the deployment with `terraform destroy`

```console
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_resource_group.lab4: Destroying... [id=/subscriptions/f1axxxxxxxxxxxxxxxxxxxxxxxxxxxd2886b/resourceGroups/Lab4]
azurerm_resource_group.lab4: Still destroying... [id=/subscriptions/f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/Lab4, 10s elapsed]
azurerm_resource_group.lab4: Destruction complete after 17s
```

## Part 3: Missing Variables

- If default values are not supplied, then you will be prompted for values when you run terraform apply
- Delete the `varaibles.tf` file from your directory and upload the file `variables1.tf` 
- The content is shown here

```terraform
variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created."
  type        = string
}
```

If you run `terraform plan`, you will be prompted for the values for the missing variables.

```console
$ terraform plan
var.resource_group_location
  The Azure region where the resource group will be created.

  Enter a value: eastus

var.resource_group_name
  The name of the resource group.

  Enter a value: Lab4


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab4 will be created
  + resource "azurerm_resource_group" "lab4" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Lab4"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "The wonder lama"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

```

## Part 4: Adding a variable file

- We can supply values to Terraform by using a `terraform.tfvars` file

- It looks like this

```terraform
# Supply values
resource_group_name     = "Lab4"
resource_group_location = "eastus2"
```

- Upload the `terraform.tfvars` file and run plan again.
- This time you will not be prompted for values


```console
 terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab4 will be created
  + resource "azurerm_resource_group" "lab4" {
      + id       = (known after apply)
      + location = "eastus2"
      + name     = "Lab4"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "The wonder lama"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

```

- Notice that the values are taken from the `terrafrom.tfvars` file.
- To show this, edit the file like this:

```terraform
# Supply values
resource_group_name     = "Lab4xxxx"
resource_group_location = "eastus2"
```
- And run plan again to see the value is different for name

```console
terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab4 will be created
  + resource "azurerm_resource_group" "lab4" {
      + id       = (known after apply)
      + location = "eastus2"
      + name     = "Lab4xxxx"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "The wonder lama"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

## Part 5: Local variables

- In this case, we change the value of the owner tag locally
- The code is in `main3.tf`


```terraform
# Lab 4 -  Variables and locals


locals {
  resource_owner = "The dev team"
}

resource "azurerm_resource_group" "lab4" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = "test environment"
    owner       = local.resource_owner
    purpose     = "demonstrate stuff"
  }
}

```

- Replace your existing `main.tf` file with this one and run `terraform plan`

```console
terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab4 will be created
  + resource "azurerm_resource_group" "lab4" {
      + id       = (known after apply)
      + location = "eastus2"
      + name     = "Lab4xxxx"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "The dev team"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```


## End Lab