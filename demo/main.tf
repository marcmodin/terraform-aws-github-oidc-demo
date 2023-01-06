# terraform provider

terraform {
  # update backend and role_arn
  # backend "s3" {
  #   bucket         = "github-oicd-demo-********"
  #   key            = "terraform-aws-github-oidc-demo/terraform.tfstate"
  #   region         = "eu-north-1"
  #   role_arn       = "arn:aws:iam::********:role/terraform-github-oicd-demo-role"
  #   dynamodb_table = "github-oicd-demo-table-********"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = "eu-north-1"

  # update role_arn
  # assume_role {
  #   role_arn     = "arn:aws:iam::********:role/terraform-github-oicd-demo-role"
  #   session_name = "terraform-aws-github-oidc-demo"
  # }

  default_tags {
    tags = {
      Environment = "dev"
      Owner       = "marc"
      Project     = "oidc-demo"
    }
  }
}


# resources
resource "aws_ssm_parameter" "foo" {
  name  = "foo-terraform-oidc-demo-role"
  type  = "String"
  value = "bar"
}

resource "aws_ssm_parameter" "bar" {
  name  = "bar-terraform-oidc-demo-role"
  type  = "String"
  value = "foo"
}

# outputs
output "foo_parameter" {
  value     = aws_ssm_parameter.foo
  sensitive = true
}

output "bar_parameter" {
  value     = aws_ssm_parameter.bar
  sensitive = true
}