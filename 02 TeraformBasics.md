# 02 Terraform Basics

---

## In this Module

- Getting started with terraform
- Structure of a terraform application
- Terraform providers and configuration
- Terraform workflow: init, validate, plan, apply and destroy
- Basic Hashicorp Configuration Language (HCL) syntax: resources, data sources, variables and outputs
- Introduction to terraform state


---

## Structure of a Terraform Application

A Terraform application is made up of modules
- A module is a directory that contains terraform source files
- Any text file with a _.tf`_ extension is a terraform source file
- We can create any kind of module structure we want

The main module that _terraform_ utility is run from is called the __root__ module
- Every terraform application has a root module
- The terraform state file is created and maintained by terraform in the root module directory. 
- You never ever do anything with or to the state file - **only** Terraform should ever modify it.
- A root module is mandatory, but we can use other ancillary modules (covered later in the course)

Terraform variables are always stored in a file named `terraform.tfvars`. There can be at most one variable file per module.

```source
Terraform Complex Application Structure
.
├── main.tf          # The primary entry point for Terraform configurations
├── variables.tf     # Defines variables used within the configuration files
├── outputs.tf       # Defines outputs from your Terraform configuration
├── terraform.tfvars # File to define values for your variables
├── modules/
│   ├── networking/  # A module for setting up network resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/     # A module for setting up compute resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── storage/     # A module for setting up storage resources
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── dev/
    │   ├── main.tf          # Terraform configuration for the dev environment
    │   ├── terraform.tfvars # Variable values for the dev environment
    │   └── backend.tf       # Configuration for Terraform state management in dev
    ├── staging/
    │   ├── main.tf
    │   ├── terraform.tfvars
    │   └── backend.tf
    └── prod/
        ├── main.tf
        ├── terraform.tfvars
        └── backend.tf
```

In this example, a naming convention has been adopted to make the code self documenting

_main.tf_: The primary entry point for Terraform configurations, this is often where the cloud provider is defined.

_variables.tf_: Defines variables that will be used across the Terraform configurations. The file can have any name as long as it has a _.tf_ suffix. The values will be set in the _*.tfvars_ files

_outputs.tf_: Terraform can extract information about the infrastructure resources. This file would define what information Terraform should output

_terraform.tfvars_: Variable values are defined in this file. It allows easy switching between different configurations for different environments or scenarios. This is the only file whose name is mandated by Terraform.

_modules/_: Modules are reusable Terraform configurations that can be used to modularize and organize your infrastructure. Each module is stored in its own subdirectory and can have its own _main.tf_, _variables.tf_, and _outputs.tf_ files.

_networking/, compute/, storage/_: These are examples of modules for different aspects of the infrastructure, like networking, compute instances, and storage.

_environments/_: This directory contains subdirectories for each environment (e.g., dev, staging, prod) that might be managed with Terraform. Each environment has its own _main.tf_ that defines the infrastructure for that environment, a _terraform.tfvars_ for environment-specific variables, and a _backend.tf_ for configuring Terraform state management specific to that environment.

Note that this is only one _possible_ way of organizing a terraform implementation.

---

## How Terraform Processes a Module

Terraform merges the contents of all the *.tf files in a directory before doing anything
- This means that you can name your *.tf files whatever you want
- You can have as many *.tf files as you want in the module
- A minimum requirement is that there should be one file that contains the information needed to initialize the Terraform application
- In our labs, we have put this minimal code into a file called `providers.tf`

Some best practices
- Files should be modular so that the organization of the Terraform code is easy to understand and maintain
- Terraform file names should be descriptive; they should document what the file contains.


There can be a single optional file _terraform.tfvars_ in each module
- This sets the values of the defined variables when Terraform executes
- This file must be named _terraform.tfvars_ exactly

Terraform ignores all other files in the module that do not have *.tf extension
- This allows for the inclusion of documentation files directly in the Terraform modules source code.

Terraform plans out the deployment by analyzing the dependencies between the infrastructure directives and creates a _directed acyclic graph_ to figure out the order elements should be created
-  For example, a network may have to be created before a compute instance can be created because the compute instance must be deployed into a network so it can be assigned an IP address.
- Terraform figures out this relationship when building the DAG, then ensures it deploys your configuration in the right order to satisfy this dependency.
- When you track how Terraform implements your resources, you can observe they are not created in the same order they appear in your files.

<img src="images/DAG.jpg" width="400" alt="">

Terraform cannot prevent semantic errors
- For example, specifying a non-existent device type or trying to create a compute instance from an invalid image, or trying to create a storage bucket using a name that is already in use.
- Terraform will just report the error and stop.
- You can either roll back the deployment manually, or make the correction and resume the deployment.

## Canonical File Names
The Terraform community has a file naming convention generally adhered to
- This makes reading terraform source code easier for other developers

The canonical names are:
- _variables.tf_: contains variable definitions
- _outputs.tf_: contains the return value (output) definitions
- _providers.tf_: contains the provider, versioning and backend configurations
- _main.tf_: contains the core code - resource definitions,etc.

If the _main.tf_ starts to become too difficult to read, it is often broken down into other files
- For example, all object bucket code might be in _buckets.tf_`

---

## Canonical Module

A typical terraform module looks like the screenshot below

It is considered a professional best practice to use this structure for all terraform work
- Additional files, like _buckets.tf_ are added when they improve the readability of the code

<img src="images/CannonicalFiles.png" width="500" alt="">

---

## Non-Canonical Modules

The screenshot below shows a non-canonical module structure
- This will still work, terraform does not care what we name the files since it merges the contents of all the files before planning the deployment
- However, the _terraform.tfvars_ file cannot be renamed or terraform will ignore it

<img src="images/NonCannoicalFiles.png" width="525" alt="">


---

## The Five Basic Terraform Constructs

1. Configuration Directives: these include _provider_ and _terraform_
2. _resource_: specifies a cloud resource managed by terraform
3. _data_ : specifics a resource in the cloud environment not managed by Terraform that we want to query to get some information about it.
4. _variable_: defines an input to a terraform module
5. _output_: defines a return value or output from the module

---

# The `terraform` block

Used to specify how to set up terraform.

- The required version of Terraform
- Specifies the plugins needed to communicate with the cloud vendor(s)
    - Defines the location of the plugins and versions
    - Defines location of the Terraform backend (covered later)

```terraform
terraform {
  required_providers {
    aws = {
    source  = "hashicorp/aws"
    }
  }
}
```
Every provider has a different set of IaaS primitives like compute resources, storage resources and networking resources

Terraform relies on these provider plugins to interact with the different cloud services. The _providers_ directive specify which providers plugins to fetch and install.

Without knowing what provider is being used, Terraform can't manage any kind of infrastructure.

---

## The Provider Directive

This contains configuration information that is specific to a provider
- Related to how the cloud resources are organized in a specific cloud provider

```terraform
provider "google" {
  project = "acme-app"
  region  = "us-central1"
}

provider "ibm" {
 region = "us-south"
}

provider "aws" {
region = "us-east-1"
}
```

There can be more than one provider
- Different providers are identified by aliases
- Represents an alternate Azure envi

[Providers Documentation](https://developer.hashicorp.com/terraform/language/providers)

---

## The Terraform Workflow

The workflow is implemented through a series of terraform commands
1. _init_ - scans the source files and updates the local providers
2. _validate_ - checks for syntax errors in the *.tf files
3. _plan_ - creates an implementation plan
4. _apply_ - implements the implementation plan
5. _destroy_ - removes all Terraform managed resources defined in this module and recorded in the state file

The _apply_ command automatically runs _validate_ and then _plan_
- _apply_ can also apply a saved plan

The _plan_ command automatically runs _validate_
- _plan_ can also save the plan to a file for later application

Running _validate_ on its own is a lot faster for quick syntax checks

---

## Terraform files

Terraform maintains a hidden directory `.terraform` and a state file `terraform.tfstate` and a backup copy of the state file `terraform.tfstate.backup`
- We will explore these files in Lab 2.

The other Terraform files that it maintains are:

- _.terraform/_ A hidden directory containing initialization moduels
- _.terraform/providers/_ Caches downloaded providers (e.g., azurerm, aws)
- _.terraform/terraform.tfstate.lock.info_ a lock file used _during terraform apply_ to avoid concurrent state writes
- _.terraform.lock.hcl_ Provider dependency lock file to ensure consistent provider versions across runs
- _.terraform/modules/_	Cached modules if you're using remote or local modules


---

## Lab 2 - Terraform Basics

---

## End 