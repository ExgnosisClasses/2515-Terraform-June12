# 7. Terraform Modules

---

## Terraform Modules Recap

In an earlier section, it was said that a Terraform application was made up of modules
- There was always a _root_ module from with Terraform was run
- So far in this class, all the work done has been in the root module

Modules are analogous to subroutines
- The root module is like the mainline
- The root module can call other modules
- And other modules can also call other modules
- Just like subroutines in code

---

# Multiple Environments

Cloud advantage: create multiple copies of the same environment
- Production, Development, Test
- Environments need to be similar if not identical
- Different environments will have parts that are exactly the same

![](images/TerraformModules1.png?raw=true)

We want to be able to re-use Terraform code across environments
- DRY Principle: "Do not repeat yourself"
- We want to write re-usable code in only one place.
- Modules allow us to reuse Terraform code

---

## Module Basics

Any folder containing terraform files is a module
- There is no special declaration or syntax required for it to be identified as a module.
- Conceptually, modules are containers for multiple resources that are used together
- Modules are the primary mechanism used to package and reuse terraform resources

Every terraform configuration has at least one module
- It is referred to as the "root" module
- It consists of the terraform files in the main working directory

Any module, not just the root, may import other or "call" other modules
- Modules that are being called are called _child_ modules

---

## Example

If we are creating the same resource in multiple configurations, we can create a reusable module for it

In this example, the configuration uses a module in the _modules/EC2_ folder to create an EC2 instance

The code for this example is in the directory `example-1/ex6-1`
The folder structure looks like this:

![](images/projectstructure.png)

Note that we are not making the module a subdirectory of the project module. This creates a spurious coupling between the project and the EC2 module.

A better practice is to thing of the modules as residing in a module library. 
- Later in code management, we will see that this allows for more effective managements of large projects and multiple modules.

---

The EC2 module looks like this. This just what we have seen before. But note that there is no providers specified

```terraform
resource "aws_instance" "alpha" {
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.nano"
    tags = {
        source = "EC2 Module"
    }
}
```

The root module in the `Project` folder has a `providers.tf` file. This is where our Terraform commands are run from which is one reason why we designate the `Project` folder as the root folder.

The actual code in the `main.tf` root module is just a reference or call to the EC2 module.

The `module` directive creates a reference to the EC2 module called `"EC2Defs"` and contains the path or where the module should be sourced from

```terraform
module "EC2Defs" {
    source = "../modules/EC2"
}
```

If we run `terraform init` from the root module, the command also initializes the specified modules.


```console
$ terraform init

Initializing the backend...
Initializing modules...
- EC2Defs in ../modules/EC2

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Installing hashicorp/aws v3.76.1...
- Installed hashicorp/aws v3.76.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

We can then confirm at the console that the EC2 instance was deployed

---

## Creating Multiple Resources

We can create multiple copies of a resource by making repeated calls to the module like so:

```terraform
module "vm1" {
    source = "../modules/EC2"
}

module "vm2" {
    source = "../modules/EC2"
}
```
This will produce two EC2 instances running but they will have identical configurations

---

## Parametrized Modules

Recall from an earlier that we can think of a module as being like a function call.

This is where we can use Terraform variables to parameterize the Module

Create the parameter variables in a `variables.tf` file

```terraform
variable "ami_type" {
    type = string
    default = "ami-080e1f13689e07408"
}

variable "inst_type" {
    type = string
    default = "t2.nano"
}

variable VM_name {
    type = string
    default = "EC2-Module"
}
```

It is considered to be a good practice during development to provide reasonable default values for the parameters so that deployments do not break from a calling module not providing a value. 

However, it may not be desirable to have defaults in a production environment where the presence of defaults masks the fact that certain parameters might not have been provided correctly. 
- This might result in a misconfigured deployment that spins up but then behaves anomalously.  
- Near-prod test runs should validate that the deployment spins up correctly without default parameters, unless the defaults are part of the specification.

Now parameterize the EC2 code

```terraform 
resource "aws_instance" "alpha" {
    ami = var.ami_type
    instance_type = var.inst_type
    tags = {
        source = "EC2 Module"
        Name = var.VM_name
    }
}
```

Now we can call create three VMs with different parameters.

```Terraform

module "vm1" {
    source = "../modules/EC2"
    ami_type = "ami-0d7a109bf30624c99"
    inst_type - "t2.medium"
    VM_name = "VM-1"
}

module "vm2" {
    source = "../modules/EC2"
    inst_type - "t2.micro"
    VM_name = "VM-2"
}

module "VM-1" {
    source = "../modules/EC2"
    VM_name = "VM-3"
  }
```

## Parameterizing Module Calls

There is still a lot of hardcoded values in the root module, so we can replace those with variables as well.

First we can create a `variables.tf` file in the root module which provides lists of values to be used in the creation of the three VMs

```terraform
variable "amis" {
    type = list(string)
}

variable "insts" {
    type = list(string)
   
}

variable names {
    type = list(string)
}
```

The corresponding `terraform.tfvars` file looks like this:

```terraform
amis = ["ami-080e1f13689e07408","ami-080e1f13689e07408","ami-0d7a109bf30624c99"]
insts = ["t2.nano", "t2.nano", "t2.micro"]
names = ["Frodo", "Gandalf", "Gollum"]
```

Then we can parameterize the root module like this:

```terraform


module "vm1" {
    source = "../modules/EC2"
    ami_type = var.amis[0]
    inst_type = var.insts[0]
    VM_name = var.names[0]

}

module "vm2" {
    source = "../modules/EC2"
    ami_type = var.amis[1]
    inst_type = var.insts[1]
    VM_name = var.names[1]

}

module "vm3" {
    source = "../modules/EC2"
     ami_type = var.amis[2]
    inst_type = var.insts[2]
    VM_name = var.names[2]
  }
```

## Using Count

There is still a lot of repeated code. In a previous module we saw how we could use `count` to create multiple copies of a resource.

Modifying the `main.tf` file with `count` cleans up the code.

```terraform
module "vm" {
    count = length(var.names)
    source = "../modules/EC2"
    ami_type = var.amis[count.index]
    inst_type = var.insts[count.index]
    VM_name = var.names[count.index]
}
```

---

## Lab 7-1

---

## Combining Modules

Generally, we need to use more than one module because we need more than one type of resource 

In addition to the Ec2 instance module, we can define a security group module that generates a security group rather than keeping the code in the EC2 module since we may need security groups for other resources other than EC2 instances.

What we are doing is emulating the same sort of architecture that is used when dividing a program up into re-usable functions or subroutines.

## The SG module

This code is available in the directory `ex6-6`

The new module is added in the same way as the `EC2` module.

![](images/sgmodule.png?raw=true)

#### Inputs

The `variables.tf` file contains the configurable parameters for the security group.

```terraform
variable "access_port" {
    description = "Access port to use for the application"
    type = number
    default = 80
}

variable "sg_name" {
    description = "The name of the security group"
    type = string
    default = "My SG"
}
```

#### Outputs

The output or return value from the module is defined in the file `outputs.tf`. What is returned is the id of the security group after it has been created so that it can be used in other modules

```terraformoutput "secgps" {
    value =aws_security_group.app_port.id
    description = "Returns the id of the security group"
}
```

#### Main Code

In the `main.tf` file, the actual code to make the security group looks like this:

```terraform
resource "aws_security_group" "app_port" {
    description = " Security group to allow access app instance"
    ingress {
    description = "OpenPort"
    from_port   = var.access_port
    to_port     = var.access_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}
```

#### Calling Code

In the root module `main.tf` file, we can see the code that calls the module:

```terraform
module "SG" {
  source = "../modules/SGroup"
  access_port = 8080
  sg_name = "My Demo"
}
```

Now we are going to change the variables file `variables.tf` for the`EC2` module to take a reference to a security group id to use.

```terraform
variable "ami_type" {
    type = string
    default = "ami-080e1f13689e07408"
}

variable "inst_type" {
    type = string
    default = "t2.nano"
}

variable VM_name {
    type = string
    default = "EC2-Module"
}

variable "sg_groups" {
    description = "Associated security groups"
    type = string
}
```

And this is how it is used in the EC2 module `main.tf` file.

```terraform
resource "aws_instance" "alpha" {
    ami = var.ami_type
    instance_type = var.inst_type
    tags = {
        source = "EC2 Module"
        Name = var.VM_name
    }

    vpc_security_group_ids = [var.sg_groups]
}

```

So the question becomes how the return value from the `SGroup` module was passed into the `EC2 module`

We can see this in the root module `main.tf` file.

```terraform

Module "vm" {
    count = length(var.names)
    source = "../modules/EC2"
    ami_type = var.amis[count.index]
    inst_type = var.insts[count.index]
    VM_name = var.names[count.index]
    sg_groups = module.SG.secgps
  }
  
 ```
 
In this code, the `sg_goups` variable for the `EC2` module is set to the output `secgps` from the module `SG`.

---


## Module Gotchas - Paths

The hard-coded file paths are interpreted as relative to the current working directory
- The problem is that this will not work if we are working with a module in a different directory

To solve this issue, you can use an expression known as a path reference, which is of the form path.<TYPE>. Terraform supports the following types of path references:
- `path.module`: Returns the file system path of the module where the expression is defined
- `path.root`: Returns the file system path of the root module
- `path.cwd`: Returns the file system path of the current working directory, usually the same as path.root
- 
---

## Module Path

In this example, the template file is located with a path relative to the module, but if we hard-code the path, it will be interpreted as relative to the current working directory

By using the `path.module` construct, we ensure the file reference remains relative to the module

 ```terraform
  data "template_file" "user_data" {
    template = file("${path.module}/user-data.sh")

    vars = {
      server_port = var.server_port
      db_address  = data.terraform_remote_state.db.outputs.address
      db_port     = data.terraform_remote_state.db.outputs.port
    }
  }
  ```

---

## Module Gotcha - Inline Blocks

The configuration for some Terraform resources can be defined either as inline blocks or as separate resources

When creating a module, you should always prefer using a separate resource

#### Inline block example

```terraform
  resource "aws_security_group" "alb" {
    name = "${var.cluster_name}-alb"

    ingress {
      from_port   = local.http_port
      to_port     = local.http_port
      protocol    = local.tcp_protocol
      cidr_blocks = local.all_ips
    }

    egress {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_ips
    }
  }
  ```
#### Separate Resource

You should change this module to define the exact same ingress and egress rules by using separate aws_security_group_rule resources

 ```terraform
  resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
  }

  resource "aws_security_group_rule" "allow_http_inbound" {
    type              = "ingress"
    security_group_id = aws_security_group.alb.id

    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  resource "aws_security_group_rule" "allow_all_outbound" {
    type              = "egress"
    security_group_id = aws_security_group.alb.id

    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
  ```
---

## Inline Blocks

Using a mix of inline blocks and separate resources may cause errors where routing rules conflict and overwrite one another
- Use one or the other
- When creating a module, you should always try to use a separate resource instead of the inline block
- This allows for more flexible modules

- For example, changing a security group rule to allow a testing port is easier to do with a separate resource than having to edit inline blocks

```terraform
  resource "aws_security_group_rule" "allow_testing_inbound" {
    type              = "ingress"
    security_group_id = module.webserver_cluster.alb_security_group_id

    from_port   = 12345
    to_port     = 12345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ```
---

## Module Versioning

If the staging and production environment point to the same module folder, any change in that folder will affect both environments on the very next deployment
- This creates a coupling between environments and modules that can cause problems

To solve this problem, we use a standard build management technique of using versions
- As changes are made to a module, releases or versions of that module are published
- Part of the configuration of any Terraform configuration plan is identification of which version of a module to include

---

## Module Versioning Layout

![](images/module-versioning.png?raw=true)


---
## Module Versioning

* An effective strategy is to use a repository tool like git and GitHub to publish releases of a module
    * Then the appropriate "release" of a module can be used

 ```terrafrom
  module "webserver_cluster" {
  source = "github.com/foo/modules//webserver-cluster?ref=v0.0.1"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "(YOUR_BUCKET_NAME)"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
  }
```

---

## Semantic Versioning

A common versioning scheme is "semantic versioning"
- The format is MAJOR.MINOR.PATCH (e.g., 1.0.4)
- There are specific rules on when you should increment each part of the version number

MAJOR version increments when you make incompatible API changes

MINOR version increments when you add functionality in a backward-compatible manner

PATCH version increments when you make backward-compatible bug fixes

---

## Lab 7-2

