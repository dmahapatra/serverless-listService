data "archive_file" "listservice_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/listservice.py"
  output_path = "listservice.zip"
}

resource "aws_lambda_function" "listservice" {
  filename         =  data.archive_file.listservice_lambda.output_path
  function_name    = "listservice-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "listservice.lambda_handler"
  runtime          = "python3.13"
  memory_size      = var.lambda_memory
  timeout          = var.lambda_timeout 

  environment {
    variables = {
      ENV        = var.environment
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}
