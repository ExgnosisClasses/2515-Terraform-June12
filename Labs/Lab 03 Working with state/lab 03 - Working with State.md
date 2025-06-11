# Lab 3: Working with state

In this lab, we do a deep dive into Terraform state

## Part 1: Deploy a resource

Just like you did in the previous labs
- Delete any previous `main.tf` file in your cloud shell
- Upload the `main.tf` file from the lab 4 directory.

```terraform
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
```

- Just like you did before, use `terraform apply` to create the resource'

```console
 terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab3 will be created
  + resource "azurerm_resource_group" "lab3" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Lab3"
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

azurerm_resource_group.lab3: Creating...
azurerm_resource_group.lab3: Creation complete after 10s [id=/subscriptions/f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3]
```

## Part 2: State file

- Examine the state file as shown:

```console
rod [ ~ ]$ more terraform.tfstate
{
  "version": 4,
  "terraform_version": "1.11.3",
  "serial": 17,
  "lineage": "fxxxxxxxxxxxxxxxxxxxxxxxxxxb7f579ce3",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "azurerm_resource_group",
      "name": "lab3",
      "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "/subscriptions/f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/Lab3",
            "location": "eastus",
            "managed_by": "",
            "name": "Lab3",
            "tags": {
              "environment": "test environment",
              "owner": "Zippy",
              "purpose": "demonstrate stuff"
            },
            "timeouts": null
          },
          "sensitive_attributes": [],
          "private": "eyJlMmJmYjczMC1lY2FhLTExZTYtOGY4OC0zNDM2M2JjN2M0YzAiOnsiY3JlYXRlIjo1NDAwMDAwMDAwMDAwLCJkZWxldGUiOjU0MDAwMDAwMDAwMDAsInJlYWQiOjMwMDAwMDAwMDAwMCwidXBkYXRlIjo1NDAwMDAwMDAwMDAwfX0="
        }
      ]
    }
  ],
  "check_results": null
}
```

- It's not important to understand all the features that Terraform is saving, since it is using a number of defaults.

## Part 3: Nondestructive change in a resource

- We can change some attributes of an existing resource
- By change, we mean that Terraform can just modify the existing resource without recreating it.
- An example of this is to change one of the tags on our RB

- Modify your `main.tf` file by changing the value of a tag like so


```terraform
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
```
- The modified code is in the file `main2.tf` in the lab directory
- Do not run Terraform with _both_ versions of this file in your cloud shell.

Run `terraform plan`
- Your output should look something like this

```console
terraform plan
azurerm_resource_group.lab3: Refreshing state... [id=/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_resource_group.lab3 will be updated in-place
  ~ resource "azurerm_resource_group" "lab3" {
        id         = "/subscriptions/f1xxxxxxxxxxxxxxxxxxxxxxxxxxxxd2886b/resourceGroups/Lab3"
        name       = "Lab3"
      ~ tags       = {
            "environment" = "test environment"
          ~ "owner"       = "Zippy" -> "The wonder lama"
            "purpose"     = "demonstrate stuff"
        }
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

```
- Notice the last line talks about making a change and shows on the line with the `~` what the change is it will make.
- Run `terraform apply` 
- You should see this output.


```console
terraform apply
azurerm_resource_group.lab3: Refreshing state... [id=/subscriptions/f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxx2886b/resourceGroups/Lab3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_resource_group.lab3 will be updated in-place
  ~ resource "azurerm_resource_group" "lab3" {
        id         = "/subscriptions/f1axxxxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3"
        name       = "Lab3"
      ~ tags       = {
            "environment" = "test environment"
          ~ "owner"       = "Zippy" -> "The wonder lama"
            "purpose"     = "demonstrate stuff"
        }
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab3: Modifying... [id=/subscriptions/f1axxxxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3]
azurerm_resource_group.lab3: Modifications complete after 1s [id=/subscriptions/f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

## Part 4: Destructive Change in a Resource

- Not all changes can be done non-destructively
- Some changes require Terraform to destroy the resource and then recreate it with the new values
- Modify the name of the RG as shown below:

```terraform
# Lab 3 state - modification 2

resource "azurerm_resource_group" "lab3" {
  name     = "ModifedLab3"
  location = "eastus"
  tags = {
      environment = "test environment"
      owner       = "The wonder lama"
      purpose     = "demonstrate stuff"
    }
}
```

- The code for this is available in `main3.tf`

Run `terraform plan`
- The output shows that Terraform will destroy one resource and create another; how it does the replace

```console
terraform plan
azurerm_resource_group.lab3: Refreshing state... [id=/subscriptions/f1a145f5-f75d-xxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # azurerm_resource_group.lab3 must be replaced
-/+ resource "azurerm_resource_group" "lab3" {
      ~ id         = "/subscriptions/f1a145f5xxxxxxxxxxxxxxxxxxxxxxd2886b/resourceGroups/Lab3" -> (known after apply)
      ~ name       = "Lab3" -> "ModifedLab3" # forces replacement
        tags       = {
            "environment" = "test environment"
            "owner"       = "The wonder lama"
            "purpose"     = "demonstrate stuff"
        }
        # (2 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

```

- Execute `terraform apply` to update the resources

```console
 terraform apply
azurerm_resource_group.lab3: Refreshing state... [id=/subscriptions/f1a145f5-f75d-4170-a316-576364d2886b/resourceGroups/Lab3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # azurerm_resource_group.lab3 must be replaced
-/+ resource "azurerm_resource_group" "lab3" {
      ~ id         = "/subscriptions/f1xxxxxxxxxxxxxxxxxxxxxxxxxxx4d2886b/resourceGroups/Lab3" -> (known after apply)
      ~ name       = "Lab3" -> "ModifedLab3" # forces replacement
        tags       = {
            "environment" = "test environment"
            "owner"       = "The wonder lama"
            "purpose"     = "demonstrate stuff"
        }
        # (2 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab3: Destroying... [id=/subscriptions/f1a145f5-f75xxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3]
azurerm_resource_group.lab3: Still destroying... [id=/subscriptions/f1a145f5-f7xxxxxxxxxxxxxxxxxxxxxx86b/resourceGroups/Lab3, 10s elapsed]
azurerm_resource_group.lab3: Destruction complete after 19s
azurerm_resource_group.lab3: Creating...
azurerm_resource_group.lab3: Still creating... [10s elapsed]
azurerm_resource_group.lab3: Creation complete after 16s [id=/subscriptions/f1a145f5-fxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/ModifedLab3]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

- Check the GUI to confirm that the changes have been made.


## Part 5: Exploring the state file

- In this section, we will be looking at the state commands.
- At your cloud shell, type `terraform state` to see the options for the state command

```console
terraform state
Usage: terraform [global options] state <subcommand> [options] [args]

  This command has subcommands for advanced state management.

  These subcommands can be used to slice and dice the Terraform state.
  This is sometimes necessary in advanced cases. For your safety, all
  state management commands that modify the state create a timestamped
  backup of the state prior to making modifications.

  The structure and output of the commands is specifically tailored to work
  well with the common Unix utilities such as grep, awk, etc. We recommend
  using those tools to perform more advanced state tasks.

Subcommands:
    list                List resources in the state
    mv                  Move an item in the state
    pull                Pull current state and output to stdout
    push                Update remote state from a local state file
    replace-provider    Replace provider in the state
    rm                  Remove instances from the state
    show                Show a resource in the state
```

#### List your resources

- Type `terraform state list` to see the resources in the state file.
- Note that the listing is `<resourcetype>.<TerraformName>`

```console
rod [ ~ ]$ terraform state list
azurerm_resource_group.lab3
rod [ ~ ]$ 
```
### Show a resource

- Now that we have a list, we can tell Terraform to show us the configuration for that resource
- To do this, execute `terraform state show azurerm_resource_group.lab3`

```console
rod [ ~ ]$ terraform state show azurerm_resource_group.lab3
# azurerm_resource_group.lab3:
resource "azurerm_resource_group" "lab3" {
    id         = "/subscriptions/f1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/ModifedLab3"
    location   = "eastus"
    managed_by = null
    name       = "ModifedLab3"
    tags       = {
        "environment" = "test environment"
        "owner"       = "The wonder lama"
        "purpose"     = "demonstrate stuff"
    }
}
```

### Remove the resource

- First, copy and save the `id` field from the show command, you will need it later
- In this case shown above,  it is
- 
``` text
"/subscriptions/f1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/ModifedLab3"
```

- Now remove the reference to the RG
- This means that Terraform cannot see the RG when refreshing state
- You have removed the resource from being managed by Terraform
- Confirm it is no longer in the state file by running `terraform state list`
```console
$ terraform state rm azurerm_resource_group.lab3
Removed azurerm_resource_group.lab3
$ terraform state list
$ 
```
- Resource still exists, check the GUI to confirm.
- It is now invisible to Terraform
- Run `terraform plan` and see that Terraform now sees it needs to create the resources

```console
terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab3 will be created
  + resource "azurerm_resource_group" "lab3" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "ModifedLab3"
      + tags     = {
          + "environment" = "test environment"
          + "owner"       = "The wonder lama"
          + "purpose"     = "demonstrate stuff"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

```

#### Resource conflict

- If you run `terraform apply`, an error will be generated.
- Since RG resource names need to be unique, when Terraform tries to create the resource group in the same region, it gets an error from Azure that a RG rresouce with that name already exists.
- Notice that this error occurs when Terraform actually tries to create the resource.

```console
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.lab3: Creating...
╷
│ Error: A resource with the ID "/subscriptions/f1xxxxxxxxxxxx4170-a316-576364d2886b/resourceGroups/ModifedLab3" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_resource_group" for more information.
│ 
│   with azurerm_resource_group.lab3,
│   on main.tf line 4, in resource "azurerm_resource_group" "lab3":
│    4: resource "azurerm_resource_group" "lab3" {
│ 
╵

```
### Importing a resource

- We have the unique Azure ID of the resource, so all we have to do is reattach it to the variable `azurerm_resource_group.lab3`
- Note we have to have a specification in a terraform file that matches the configuration of the running resource
- Import using the ID you recoded earlier
- `terraform immport "variablename>" "<id">`

```console
terraform import "azurerm_resource_group.lab3"  "/subscriptions/f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/ModifedLab3"
azurerm_resource_group.lab3: Importing from ID "/subscriptions/f1axxxxxxxxxxxxxxxxxxxxxxxxxxxx2886b/resourceGroups/ModifedLab3"...
azurerm_resource_group.lab3: Import prepared!
  Prepared azurerm_resource_group for import
azurerm_resource_group.lab3: Refreshing state... [id=/subscriptions/f1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/ModifedLab3]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

rod [ ~ ]$ terraform plan
azurerm_resource_group.lab3: Refreshing state... [id=/subscriptions/f1axxxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/ModifedLab3]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

## Clean up

- Run `terraform destroy` to clean up Azure and then delete the `main.t` file and its variants
- Leave the `providers.tf` in place

---

## End Lab
