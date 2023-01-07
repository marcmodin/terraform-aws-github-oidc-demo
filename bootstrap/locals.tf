locals {
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = format("%s-%s", var.name_prefix, local.account_id)
  table_name  = format("%s-lock-%s", var.name_prefix, local.account_id)
}

data "aws_caller_identity" "current" {}
