# Version 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = var.profile_name
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name = var.api_gateway
}

# Create /book resource 
resource "aws_api_gateway_resource" "book_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = var.api_gateway_book_path
}

resource "aws_api_gateway_method" "book_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.book_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create /cancel resource
resource "aws_api_gateway_resource" "cancel_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = var.api_gateway_cancel_path
}

resource "aws_api_gateway_method" "cancel_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.cancel_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# IAM Role for lambda execution with
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create Lambda function for booking 
resource "aws_lambda_function" "booking_ack_req" {
  function_name = var.book_ack_req
  runtime       = var.runtime
  handler       = "lambda_function.lambda_handler"
  filename      = "../${var.book_ack_req}.zip" # Replace with your actual Lambda code
  role          = aws_iam_role.lambda_execution_role.arn
  # Other Lambda function configurations...
}
resource "aws_lambda_permission" "book_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.booking_ack_req.arn
  principal     = "apigateway.amazonaws.com"

  # API Gateway resource ARN
  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/${aws_api_gateway_method.book_method.http_method}${aws_api_gateway_resource.book_resource.path}"
}
resource "aws_api_gateway_integration" "book_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.book_resource.id
  http_method             = aws_api_gateway_method.book_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.booking_ack_req.invoke_arn
}


# Create Lambda Function for cancelling
resource "aws_lambda_function" "cancel_ack_req" {
  function_name = var.cancel_ack_req
  runtime       = var.runtime
  handler       = "lambda_function.lambda_handler"
  filename      = "../${var.cancel_ack_req}.zip" # Replace with your actual Lambda code
  role          = aws_iam_role.lambda_execution_role.arn
  # Other Lambda function configurations...
}
resource "aws_lambda_permission" "cancel_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cancel_ack_req.arn
  principal     = "apigateway.amazonaws.com"

  # API Gateway resource ARN
  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/${aws_api_gateway_method.cancel_method.http_method}${aws_api_gateway_resource.cancel_resource.path}"
}
resource "aws_api_gateway_integration" "cancel_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.cancel_resource.id
  http_method             = aws_api_gateway_method.cancel_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.cancel_ack_req.invoke_arn
}
