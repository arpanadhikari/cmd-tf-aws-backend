locals {
  workspace_key_prefix = var.workspace_key_prefix != "" ? "${var.workspace_key_prefix}/" : ""
}

data "aws_iam_policy_document" "backend_assume_role_all" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = length(var.all_workspaces_details) > 0 ? var.all_workspaces_details : tolist([data.aws_caller_identity.current.account_id])
    }
  }
}

data "aws_iam_policy_document" "iam_role_policy_all" {
  statement {
    actions = [
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketTagging",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketVersioning"
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.backend.id}"]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.backend.id}/*"]
  }

  statement {
    actions   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:*:*:table/${var.resource_prefix}-terraform-lock"]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = var.enable_customer_kms_key ? [aws_kms_key.backend[0].arn] : []
  }
}

data "aws_iam_policy_document" "backend_assume_role_restricted" {
  for_each = var.workspace_details

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = length(each.value) > 0 ? each.value : tolist([data.aws_caller_identity.current.account_id])
    }
  }
}

data "aws_iam_policy_document" "iam_role_policy_restricted" {
  for_each = var.workspace_details

  statement {
    actions = [
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketTagging",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketVersioning"
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.backend.id}"]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.backend.id}/${local.workspace_key_prefix}${each.key}*"]
  }

  statement {
    actions   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:*:*:table/${var.resource_prefix}-terraform-lock"]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = var.enable_customer_kms_key ? [aws_kms_key.backend[0].arn] : []
  }
}
