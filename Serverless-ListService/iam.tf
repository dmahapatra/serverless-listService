# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "listservice-lambda-role-${var.environment}"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Basic Lambda execution (logs, metrics)
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB read-only access
resource "aws_iam_policy" "dynamodb_read_policy" {
  name = "listservice-dynamodb-readonly-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_table_name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_read_policy.arn
}
