# 04 Terraform Variables

---


## Terraform Variables

Variables are used to replace hardcoded values, like the region or  type, in Terraform code 

Variables are typed, like in a programming language, but default to string if a type is not explicitly defined

Variables can have an optional default value 

If a value for a variable is not provided, then the user is prompted to supply a value at the command line when `terraform plan` is run 

Variables are reference by using the syntax:
- `var.<variable-name>`
- An older deprecated syntax that might appear in legacy code is `${var.<variable-name>}`

---

## Defining Variables

In the following example (example-3 in the repository)

The `variables.tf` file defines three variables
- There is a default defined for the `ami_type`
- The default is used _only_ if the variable is not assigned a value anywhere 
- The default ensures that the user will not be prompted for a value at the command line 

```terraform
variable "ami_type" {
  description = "The ami type to be used for the VM"
  type        = string
  default     = "ami-0f403e3180720dd7e"
}

variable "inst_type" {
    description = "Instance type for the VM"
    type = string
}

variable "bucket_name" {
    description = "Name of the bucket to be created"
    type = string
}
```

The values for the variables are defined in the `terraform.tfvars` file

```terraform
ami_type = "ami-080e1f13689e07408"
inst_type = "t2.nano"
bucket_name = "fried-onion-snacks-9987"
```

---

## Using Variables

The hardcoded values for the arguments can now be replaced with variables

```terraform
resource "aws_instance" "my_vm" {
  instance_type = var.inst_type
  ami           = var.ami_type
  tags = {
    Name = "Terraform"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}
```

---

## Overriding Variables

We may want to override the defined variables in the `terraform.tfvars` temporarily.

We can define a file name `*.auto.tfvars` that will override the `terraform.tfvars` file
- For example, we may want to use a different configuration of a vm for testing purposes so we would define that in a `testing.auto.tfvars file` which would override the value in the `terraform.tfvars` file.

Using the `*.auto.tfvars` file prevents having to rewrite the `terraform.tfvars` file to make changes to configuration.

If there is a set of values that remain constant in all deployments, the should be in the `terraform.tfvars` file. 

The name of the `*.auto.tfvars` file should be descriptive as to what it is doing.

The `*.auto.tfvars` files can be used to add to the `terraform.tfvars` file to flesh out deployments in different environments like prod, dev, test, etc,

If you are using multiple `*.auto.tfvars`, they will be processed in lexical order so that if the variable `bucket_name` is defined in `dev.auto. tfvars` and `test.auto.tfvars`, then the definition in `test.auto.tfvars` 


## Variables and Outputs

It is helpful to think of a Terraform module as analogous to a function call
- The Terraform variables are analogous to the parameters to the function
- The outputs are analogous to the return value of the function

The `variables.tf` file we were using is analogous to a parameter list
- It defines the variables used in the Terraform module
- When we run the code, the `terraform.tfvars` file provides the values for those parameters
- This is why if we don't supply a value or a default, we are prompted for one.

The `outputs.tf` file defines a series of named return values
- Since we have been working only with the root module, the only thing we have been able to do with them so far is just print them out.

---

## Local Variables

Just like in a function in a programming language, we can have local variables in a Terraform module.
- Local variables cannot be referenced outside the module
- Local variables are defined in a `locals` block
- Local variable definitions can be split across more than one `locals` block
- Local variables are referenced with the syntax `local.<name>`

The purpose of local variables is to avoid repeating hardcoded values in a module
- These values are generally not parameterizing the deployment
- They often represent meta-data like tags

The primary functions and benefits of using local variables are:

- _Complex Expressions:_ If a complex expression needs to be used multiple times within a module, it can be defined once as a local variable then referenced where needed
- _Improving Readability:_ Assigning meaningful names to complex expressions or frequently used values makes the Terraform configuration code more readable. The local variables document the code.
- _Enhancing Maintainability:_ When changes to a value used in multiple places within your module, the change needs only be done once in the locals block.
- _Organizational Benefits:_ Local variables can be used to group related values together in a way that makes logical sense, which can be particularly useful for organizing configurations that involve multiple resources with related settings.

---

## Example

Suppose we have several teams that will be deploying the same Terraform configuration. 
- Each team is required to tag their resources with the name of their team
- And to tag the source from which the resource was created.

The tags can be added to each resource like this:

```terraform
esource "aws_instance" "my_vm" {
  instance_type = var.inst_type
  ami           = var.ami_type
  tags = {
    Source = "Terraform"
    Team = "Dev Team 1"
    Name = "Main Server"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = {
  Source = "Terraform"
    Team = "Dev Team 1"
  }
}
```
There are several problems with this approach.
- There is a lot of manual editing that needs to be done
- There will be multiple copies of this file just to accommodate a minor difference

We want to avoid putting this sort of metadata into actual variables since they really are not parameters that change the actual deployment configuration

Instead, we define these in `local` block, which in this example is defined in the file `locals.tf'
- This file is still inside the module so any other file inside the module can see it.

```terraform
locals {
    source = "Terraform"
    team ="Dev Team 1"
}
```

These locals replace the hardcoded values like this.

```terraform
resource "aws_instance" "my_vm" {
  instance_type = var.inst_type
  ami           = var.ami_type
  tags = {
    Source = local.source
    Team = local.team
    Name = "Main Server"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = {
   Source = local.source
    Team = local.team
  }
}
```


---

## End Module