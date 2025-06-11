# 6 Terraform Outputs

---

## The "output" Directive

Returns a value, usually an attribute of AWS resource
- In the root module, the value is returned to the command line where it is printed out
- We can also specify an output file where the returned values will be stored

Including a description is considered to be a best practice

The `value` parameter is what the defined output returns

In the following code, three outputs are defined.
- Each has an arbitrary name we provided
- Each has a description
- Each output has a value

```terraform
output "EC2_Public_IP" {
    description = "The public IP address of my_vm"
    value = aws_instance.my_vm.public_ip
}
output "VPC_id"  {
    description = "The id of the default VPC"
    value = data.aws_vpc.default_vpc.id    
}

output "S3_ARN" {
    description = "ARN of the S3 bucket"
    value = aws_s3_bucket.my_bucket.arn
}
```

When running `terraform apply`, Terraform displays the defined outputs.

```console
Outputs:

EC2_Public_IP = "23.22.28.253"
S3_ARN = "arn:aws:s3:::zippy-the-wonder-llama"
VPC_id = "vpc-43898f39"
```

---


## Why use outputs?

**Sharing Data Within a Terraform Configuration:** Outputs can be used to pass information between modules, making it possible to use the output of one module as an input to another. More on that later

**Inspection:** Outputs are a way to extract particular values of interest. Particularly useful for values that are not known up front and are only assigned after a resource is created, like a dynamically assigned public IP address of a cloud instance.

**Integration with External Tools and Scripts:** Output values can be queried using the terraform output command which allows integration other tools that may need information about the infrastructure, such as deployment scripts, CI/CD pipelines, or monitoring systems.

**Documentation:** Outputs record important properties of the resources that have been deployed.

## The 'terraform output' command

The results of the outputs are kept in the state file and can be queried using this command.

All the outputs can be listed

```console
terraform output
EC2_Public_IP = "54.157.7.65"
S3_ARN = "arn:aws:s3:::zippy-the-wonder-llama"
VPC_id = "vpc-43898f39"
```

Or a single output

```console
terraform output S3_ARN
"arn:aws:s3:::zippy-the-wonder-llama"
```

Or in different formats for portability

```console
terraform  output -json
{
  "EC2_Public_IP": {
    "sensitive": false,
    "type": "string",
    "value": "54.157.7.65"
  },
  "S3_ARN": {
    "sensitive": false,
    "type": "string",
    "value": "arn:aws:s3:::zippy-the-wonder-llama"
  },
  "VPC_id": {
    "sensitive": false,
    "type": "string",
    "value": "vpc-43898f39"
  }
}
```

---

## String Interpolation

Any attribute or value can be embedded in a string by using _string interpolation_

The interpolation syntax is ${value} to insert "value" into string

Non-string values are converted to a string for interpolation

For example, to use string interpolation in the previous example, (ex2-2)

```terraform
output "EC2_Public_IP" {
    description = "The public IP address of my_vm"
    value = "The public id of my vm is ${aws_instance.my_vm.public_ip} "
}
output "VPC_id"  {
    description = "The id of the default VPC"
    value = "${data.aws_vpc.default_vpc.id} is the id of the default VPC"    
}

output "S3_ARN" {
    description = "ARN of the S3 bucket"
    value = "${aws_s3_bucket.my_bucket.arn} is the arn of the bucket ${aws_s3_bucket.my_bucket.bucket}"
}
```
Which produces the following output.

```console
Outputs:

EC2_Public_IP = "The public id of my vm is 3.91.28.188 "
S3_ARN = "arn:aws:s3:::zippy-the-wonder-llama is the arn of the bucket zippy-the-wonder-llama"
VPC_id = "vpc-43898f39 is the id of the default VPC"
```

---

## End Module
