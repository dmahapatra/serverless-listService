variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "The environment to deploy to (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "persist" {
  description = "Whether to persist data in DynamoDB"
  type        = bool
  default     = false
}

variable "lambda_memory" {
  type    = number
  default = 512
}

variable "lambda_timeout" {
  type    = number
  default = 10
}

# Existing DynamoDB table name
variable "dynamodb_table_name" {
  type    = string
  default = "list_service_dynmo"
}

variable "list_id_value" {
  description = "The ID of the list to fetch"
  type        = string
  default     = "list"
}