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

resource "aws_api_gateway_method" "book_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.cancel_resource.id
  http_method   = "POST"
  authorization = "NONE"
}


