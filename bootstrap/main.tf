
module "remote-state-bucket" {
  # below is a private module source. replace with another module, eg. source  = "cloudposse/tfstate-backend/aws"
  source        = "git@github.com:playgroundcloud/terraform-aws-remote-state-s3.git?ref=v0.0.3"
  bucket_name   = local.bucket_name
  dynamodb_name = local.table_name
  noncurrent_version_lifecycle_rule_enable = true
}

output "backend" {
  value = module.remote-state-bucket.backend_config
}