resource "aws_s3_bucket" "app" {
  bucket = "${var.name_prefix}-data"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-data"
    },
  )
}

resource "aws_s3_bucket_ownership_controls" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "/ecs/${var.name_prefix}"
    },
  )
}

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.name_prefix}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-task-execution"
    },
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  for_each = toset(var.ecs_task_execution_policies)

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = each.value
}

data "aws_iam_policy_document" "ecs_task_execution_extra" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.ecs.arn}:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_execution_extra" {
  name        = "${var.name_prefix}-ecs-task-execution-extra"
  description = "Additional permissions for ECS task execution role."

  policy = data.aws_iam_policy_document.ecs_task_execution_extra.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-task-execution-extra"
    },
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_extra" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution_extra.arn
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.name_prefix}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-task"
    },
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_managed" {
  for_each = toset(var.ecs_task_additional_policies)

  role       = aws_iam_role.ecs_task.name
  policy_arn = each.value
}

data "aws_iam_policy_document" "ecs_task_inline" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_inline" {
  name        = "${var.name_prefix}-ecs-task-inline"
  description = "Application-level permissions for ECS tasks."

  policy = data.aws_iam_policy_document.ecs_task_inline.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-task-inline"
    },
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_inline" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_inline.arn
}

