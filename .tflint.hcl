plugin "aws" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_s3_bucket_versioning" {
  enabled = true
}
