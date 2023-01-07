
# This role is created for the demo

locals {
  role_name_prefix = "terraform-github-oicd-demo-role"
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = "AllowSSMParameter"
    actions = [
      "ssm:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid       = "AllowReadCallerId"
    actions   = ["sts:GetCallerIdentity"]
    effect    = "Allow"
    resources = ["*"]
  }

  # TODO: only allow this specific bucket
  statement {
    sid = "AllowS3DynamoDb"
    actions = [
      "s3:ListAllMyBuckets",
      "dynamodb:ListTables",
      "s3:ListBucket"
    ]
    effect = "Allow"
    resources = [
    "*"]
  }

  statement {
    sid = "AllowS3BackendOperations"
    actions = [
      "s3:Get*",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    effect = "Allow"
    resources = [
      format("arn:aws:s3:::%s", local.bucket_name),
      format("arn:aws:s3:::%s/*", local.bucket_name),
    ]
  }

  statement {
    sid = "AllowDynamboDBBackendOperations"
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"

    ]
    effect = "Allow"
    resources = [
      format("arn:aws:dynamodb:*:*:table/%s", local.table_name)
    ]
  }
}

# IAM policy
#########################################
module "iam_policy" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name        = format("%s-p", local.role_name_prefix)
  path        = "/"
  description = format("%s policy", local.role_name_prefix)
  policy      = data.aws_iam_policy_document.policy.json
}

module "iam_assumable_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_arns = [
    "arn:aws:iam::${local.account_id}:root"
  ]

  create_role = true

  role_name         = local.role_name_prefix
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.iam_policy.arn
  ]
  number_of_custom_role_policy_arns = 1
}

output github-oicd-demo-role_arn {
  value = module.iam_assumable_role.iam_role_arn 
}