#This role has full access to every environment
resource "aws_iam_role" "backend_all" {
  name               = "${var.resource_prefix}-terraform-backend"
  description        = "Allows access to all Terraform workspaces"
  assume_role_policy = data.aws_iam_policy_document.backend_assume_role_all.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "backend_all" {
  name   = "${var.resource_prefix}-terraform-backend"
  role   = aws_iam_role.backend_all.id
  policy = data.aws_iam_policy_document.iam_role_policy_all.json
}

#These roles are limited to their specific workspace through the use of S3 resource permissions
resource "aws_iam_role" "backend_restricted" {
  for_each = var.workspace_details

  name               = "${var.resource_prefix}-terraform-backend-${each.key}"
  description        = "Allows access to the ${each.key} workspace prefix"
  assume_role_policy = data.aws_iam_policy_document.backend_assume_role_restricted[each.key].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "backend_restricted" {
  for_each = var.workspace_details

  name   = "${var.resource_prefix}-terraform-backend-${each.key}"
  role   = aws_iam_role.backend_restricted[each.key].id
  policy = data.aws_iam_policy_document.iam_role_policy_restricted[each.key].json
}
