resource "aws_s3_bucket_policy" "s3_bucket_policy_restricted" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  dynamic "statement" {
    for_each = var.workspace_details
    content {
      actions = ["s3:*"]
      resources = [
        "arn:aws:s3:::${aws_s3_bucket.backend.id}/${local.workspace_key_prefix}${statement.key}*",
        "arn:aws:s3:::${aws_s3_bucket.backend.id}"
      ]
      principals {
        type        = "AWS"
        identifiers = flatten(statement.value)
      }
    }
  }
} 