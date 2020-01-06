# conftest-hcl-no-variable-expansion

I'm using this to highlight the shortcomings that Conftest unfortunately has with HCL/HCL2 support, as of 1/6/2020. Primarily has to do with variable expansion.

### Where conftest works

Conftest's HCL parser does not support variable expansion. This means that conftest **does support** Terraform files like this.

* main.tf:

```hcl
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "insecure-bucket"
  acl    = "public"
}
```

* To validate, run `conftest parse hardcoded-vars/main.tf -i hcl`. It will look like this:

```json
{
	"resource.aws_s3_bucket.insecure_bucket": {
		"acl": "public",
		"bucket": "insecure-bucket"
	}
}
```


### Where conftest does not work (variable expansion)
But it will **not support** Terraform files like this:

* main.tf

```hcl
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = var.bucket
  acl    = var.acl
}
```

* variables.tf

```hcl
variable "bucket" {
  default = "insecure-bucket"
}

variable "acl" {
  default = "public"
}
```

* To validate, run `conftest parse interpolated-vars/main.tf interpolated-vars/variables.tf -i hcl`

```text
interpolated-vars/main.tf
{
	"resource.aws_s3_bucket.insecure_bucket": {
		"acl": "${var.acl}",
		"bucket": "${var.bucket}"
	}
}
interpolated-vars/variables.tf
{
	"variable.acl": {
		"default": "public"
	},
	"variable.bucket": {
		"default": "insecure-bucket"
	}
}

```

Notice lines 4-5 in the code snippet above. It shows that rather than the variable values being rendered as `"acl": "public"` and `"bucket": "insecure-bucket"`, the `${var.variable_name}` syntax was rendered literally.

## The point

If variable expansion is not supported, then conftest + HCL/HCLv2 *may* be relegated to a future of per-repository unit tests only. But if we can get variable expansion added to the parser, then we'll be able to leverage conftest for true security static analysis of Terraform code from a centralized scanner. Basically it can be [terrascan](https://github.com/cesar-rodriguez/terrascan/), but with easy to write rules and natural support for it.

Let me know what you think.