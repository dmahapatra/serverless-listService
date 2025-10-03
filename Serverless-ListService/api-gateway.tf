resource "aws_api_gateway_rest_api" "listservice" {
  name        = "ListService-${var.environment}"
  description = "Serverless ListService API (head & tail endpoints)"
}

# Resources
resource "aws_api_gateway_resource" "head_resource" {
  rest_api_id = aws_api_gateway_rest_api.listservice.id
  parent_id   = aws_api_gateway_rest_api.listservice.root_resource_id
  path_part   = "head"
}

resource "aws_api_gateway_resource" "tail_resource" {
  rest_api_id = aws_api_gateway_rest_api.listservice.id
  parent_id   = aws_api_gateway_rest_api.listservice.root_resource_id
  path_part   = "tail"
}

# Methods
resource "aws_api_gateway_method" "head_get" {
  rest_api_id   = aws_api_gateway_rest_api.listservice.id
  resource_id   = aws_api_gateway_resource.head_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "tail_get" {
  rest_api_id   = aws_api_gateway_rest_api.listservice.id
  resource_id   = aws_api_gateway_resource.tail_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrations
resource "aws_api_gateway_integration" "head_integration" {
  rest_api_id             = aws_api_gateway_rest_api.listservice.id
  resource_id             = aws_api_gateway_resource.head_resource.id
  http_method             = aws_api_gateway_method.head_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.listservice.invoke_arn
}

resource "aws_api_gateway_integration" "tail_integration" {
  rest_api_id             = aws_api_gateway_rest_api.listservice.id
  resource_id             = aws_api_gateway_resource.tail_resource.id
  http_method             = aws_api_gateway_method.tail_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.listservice.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.listservice.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.listservice.execution_arn}/*/*"
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.head_integration,
    aws_api_gateway_integration.tail_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.listservice.id
}

# Stage (instead of stage_name in deployment)
resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.listservice.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.environment
}
