output "api_endpoint" {
  value = "${aws_api_gateway_deployment.deployment.id}"
  description = "The id of the API Gateway"
}

output "lambda_name" {
  value = aws_lambda_function.listservice.arn
  description = "The ARN of the Lambda function"
}