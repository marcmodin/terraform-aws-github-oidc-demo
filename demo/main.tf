# terraform provider
terraform {
  # add backend once bootstrap has deployed
}

provider "aws" {
  region = "eu-north-1"

  assume_role {
    role_arn     = "" # add role arn from bootstrapped role
    session_name = "github-oidc-demo"
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