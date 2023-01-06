locals {
  name_prefix = "playgroundtech-github-action-oidc-role"
  account_id  = data.aws_caller_identity.current.account_id
  # update this list or create a variable that can passed in as a file or something to add new roles
  allow_roles_list = [
    "arn:aws:iam::${local.account_id}:role/terraform-oidc-demo-role"
  ]
}

data "aws_caller_identity" "current" {}

# Create the oidc provider
module "oidc_provider" {
  source = "github.com/philips-labs/terraform-aws-github-oidc?depth=1&ref=v0.6.0//modules/provider"
}

# The permissions boundary policy data
data "aws_iam_policy_document" "oidc_sts_boundary" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["*"]
  }
}

# Create permissions boundary for the oidc role
resource "aws_iam_policy" "boundary" {
  name        = format("%s-boundary", local.name_prefix)
  description = format("%s-boundary", local.name_prefix)
  path        = "/boundary/"
  policy      = data.aws_iam_policy_document.oidc_sts_boundary.json
}

# The oidc role policy data only allows assuming another role
data "aws_iam_policy_document" "oidc_sts" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    # add more or change the role name to the role used in the other terraform repos
    resources = local.allow_roles_list
  }
}

# Create the oidc role policy
resource "aws_iam_policy" "policy" {
  name        = format("%s-policy", local.name_prefix)
  description = format("%s-policy", local.name_prefix)
  policy      = data.aws_iam_policy_document.oidc_sts.json
}

# The oidc role can only assume other roles defined in the policy
module "iam_assumable_role_with_oidc" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = local.name_prefix
  role_permissions_boundary_arn = aws_iam_policy.boundary.arn
  role_policy_arns = [
    aws_iam_policy.policy.arn
  ]
  number_of_role_policy_arns = 1
  provider_url               = module.oidc_provider.openid_connect_provider.url
  # only allow repos that start with 'terraform-aws'
  oidc_subjects_with_wildcards   = ["repo:playgroundtech/terraform-aws-*:*"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

}

#TODO: add `AWS_DEV_OIDC_ROLE` and `AWS_DEV_OIDC_REGION` outputs to github secret with the github provider

output "AWS_DEV_OIDC_ROLE" {
  value = module.iam_assumable_role_with_oidc.iam_role_arn
}

output "AWS_DEV_OIDC_REGION" {
  value = var.region
}