data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "random_password" "db" {
  length              = 24
  special             = true
  override_characters = "!#$%&*()-_=+[]{}<>?@"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnets"
    },
  )
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-sg"
    },
  )
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.name_prefix}/rds/postgresql"
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-secret"
    },
  )
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "postgres"
    host     = ""
    port     = 5432
    dbname   = var.db_name
  })
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name_prefix}-postgresql"
  family = "postgres16"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-postgresql"
    },
  )
}

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-postgres"

  engine                       = "postgres"
  engine_version               = "16.3"
  instance_class               = var.db_instance_class
  allocated_storage            = var.db_allocated_storage
  storage_encrypted            = true
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.db.id]
  multi_az                     = var.multi_az
  username                     = var.db_username
  password                     = random_password.db.result
  db_name                      = var.db_name
  backup_retention_period      = var.backup_retention_period
  deletion_protection          = true
  publicly_accessible          = false
  apply_immediately            = true
  parameter_group_name         = aws_db_parameter_group.this.name
  auto_minor_version_upgrade   = true
  copy_tags_to_snapshot        = true
  performance_insights_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-postgres"
    },
  )
}

data "aws_iam_policy_document" "rotation_lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rotation_lambda" {
  name               = "${var.name_prefix}-rds-rotation-lambda"
  assume_role_policy = data.aws_iam_policy_document.rotation_lambda_assume.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-rotation-lambda"
    },
  )
}

data "aws_iam_policy_document" "rotation_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]

    resources = [aws_secretsmanager_secret.db.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "rds:DescribeDBInstances",
      "rds:ModifyDBInstance",
    ]

    resources = [aws_db_instance.this.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name_prefix}-rds-rotation:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "rotation_lambda" {
  name   = "${var.name_prefix}-rds-rotation"
  policy = data.aws_iam_policy_document.rotation_lambda.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-rotation"
    },
  )
}

resource "aws_iam_role_policy_attachment" "rotation_lambda" {
  role       = aws_iam_role.rotation_lambda.name
  policy_arn = aws_iam_policy.rotation_lambda.arn
}

resource "aws_lambda_function" "rotation" {
  function_name = "${var.name_prefix}-rds-rotation"
  role          = aws_iam_role.rotation_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = var.rotation_lambda_filename
  timeout       = 30
  memory_size   = 256

  vpc_config {
    subnet_ids         = var.rotation_lambda_subnet_ids
    security_group_ids = var.rotation_lambda_security_group_ids
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-rotation"
    },
  )
}

resource "aws_secretsmanager_secret_rotation" "db" {
  secret_id           = aws_secretsmanager_secret.db.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }

  depends_on = [aws_secretsmanager_secret_version.db]
}

