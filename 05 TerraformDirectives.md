# 05 Terraform Directives

---

## The Five Basic Terraform Constructs

1. Configuration Directives: these include _provider_ and _terraform_
2. _resource_: specifies a cloud resource managed by Terraform
3. _data_ : specifics a resource in the cloud environment not managed by Terraform that we want to query to get some information about it.
4. _variable_: defines an input to a Terraform module
5. _output_: defines a return value or output from a Terraform module

--- 

## Terraform Directives

Consider the following AWS directives in the `main.tf`file

Two resources are defined in the file that are going to be managed by Terraform
- An Azure blob storage
- An Azure Virtual machine


The `'main.tf` file looks like this

```terraform
resource "aws_instance" "my_vm" {
  instance_type = "t2.micro"
  ami           = "ami-0f403e3180720dd7e"
  tags = {
    Name = "Demo VM"
  }
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "zippy-the-wonder-llama"
}

data "aws_vpc" "default_vpc" {
    default = true
}
```

---


## The "resource" Directive - Arguments

Resource directives always start with the _resource_
- Followed by a string ("aws_instance") which identifies the type of resource
- Followed by a second string ("my_vm") which is how the resource is referred to in the Terraform code. Think of it a source code variable.
- Followed by a list of arguments used to create the resource
    - Some arguments are mandatory, like the _ami_ and _instance_type_ for an EC2 instance. Failure to provide these will cause an error.
    - Some arguments are mandatory but have defaults, like _versioning_ on S3 buckets. If a value is not specified in the Terraform code, then the default will be used.
    - Some arguments are optional, like defined tags, which don't have any value unless they are defined in the Terraform code.
- For each resource, there is a documentation page describing all the attributes associated with a specific resource and examples of how to use the resource

[Azure Resource Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)



---

## The "resource" Directive - Attributes

Some properties of a resource are assigned by the cloud provider
- These are referred to as _attributes_
- Like public_ip of a VM instance or the id of a blob storage for example
- These are created by the cloud provider when the resource is created and can be accessed in the Terraform code after the resource is created
- Remember that Terraform creates a plan for implementing resources which is based in part on the dependencies among the resources being implemented.

Syntax for accessing and attribute is: `<resource type>.<terraform name>.attribute name`

For example, the public IP of "my_vm", the EC2 instance created in the example would be:
- `aws_instance.my_vm.public_ip`

Once created, all the arguments we provided are also accessible as attributes
- The documentation page for each resource lists all the attributes available


---

## The "data" Directive

References a type of resource that is not under Terraform management, usually a pre-existing item of infrastructure, like a resource group, that needs to be referenced in the Terraform code.
- We supply whatever attributes are necessary to identify the specific resource we want to get a reference to. (More on this in a later module)
- If the resource was created the resource with Terraform, we can reference the attributes directly using the name we supplied like "my_vm" instead of using the _data_ directive.


The _data_ directive will be explored in greater depth in a later module.

---




## End Module
