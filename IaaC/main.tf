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
resource "aws_iam_role_policy" "lambda_execution_role_policy" {
  name = "CloudWatchLogsPolicy"
  role = aws_iam_role.lambda_execution_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "lambda_execution_role_policy2" {
  name = "SQSPolicy"
  role = aws_iam_role.lambda_execution_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
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
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.book_queue.url
    }
  }
}
resource "aws_lambda_permission" "book_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.booking_ack_req.arn
  principal     = "apigateway.amazonaws.com"

  # API Gateway resource ARN
  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/${aws_api_gateway_method.book_method.http_method}${aws_api_gateway_resource.book_resource.path}"
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
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.cancel_queue.url
    }
  }
}
resource "aws_lambda_permission" "cancel_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cancel_ack_req.arn
  principal     = "apigateway.amazonaws.com"

  # API Gateway resource ARN
  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/${aws_api_gateway_method.cancel_method.http_method}${aws_api_gateway_resource.cancel_resource.path}"
}
resource "aws_api_gateway_integration" "cancel_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.cancel_resource.id
  http_method             = aws_api_gateway_method.cancel_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.cancel_ack_req.invoke_arn
}

#booking queue
resource "aws_sqs_queue" "book_queue" {
  name                      = var.book_sqs_queue
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  tags = {
    Environment = var.book_sqs_queue
  }
}


#cancel queue
resource "aws_sqs_queue" "cancel_queue" {
  name                      = var.cancel_sqs_queue
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  tags = {
    Environment = var.cancel_sqs_queue
  }
}


# payment lambda function for book
# IAM Role for lambda execution with
resource "aws_iam_role" "lambda_execution_role_payment" {
  name = "lambda_execution_role_payment_function"

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
resource "aws_iam_role_policy" "lambda_execution_role_payment_policy" {
  name = "CloudWatchLogsPolicy"
  role = aws_iam_role.lambda_execution_role_payment.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "lambda_execution_role_payment_policy1" {
  name = "SNSandSQSPolicy"
  role = aws_iam_role.lambda_execution_role_payment.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sns:*",
                "sqs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

# Create Lambda function for booking 
resource "aws_lambda_function" "booking_payment_success" {
  function_name = var.book_payment_function
  runtime       = var.runtime
  handler       = "lambda_function.lambda_handler"
  filename      = "../${var.book_payment_function}.zip" # Replace with your actual Lambda code
  role          = aws_iam_role.lambda_execution_role_payment.arn
  timeout       = 10
  # Other Lambda function configurations...
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.book_queue.url
      TOPIC_ARN = aws_sns_topic.book_sns.arn
    }
  }
}

resource "aws_lambda_permission" "book_payment_lambda_permission" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.booking_payment_success.arn
  principal     = "sqs.amazonaws.com"

  source_arn = aws_sqs_queue.book_queue.arn
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.book_queue.arn
  function_name    = aws_lambda_function.booking_payment_success.arn
}

# Create Lambda function for cancel
resource "aws_lambda_function" "cancel_payment_success" {
  function_name = var.cancel_payment_function
  runtime       = var.runtime
  handler       = "lambda_function.lambda_handler"
  filename      = "../${var.cancel_payment_function}.zip" # Replace with your actual Lambda code
  role          = aws_iam_role.lambda_execution_role_payment.arn
  timeout       = 10
  # Other Lambda function configurations...
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.cancel_queue.url
      TOPIC_ARN = aws_sns_topic.cancel_sns.arn
    }
  }
}

resource "aws_lambda_permission" "cancel_payment_lambda_permission" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cancel_payment_success.arn
  principal     = "sqs.amazonaws.com"

  # API Gateway resource ARN
  source_arn = aws_sqs_queue.cancel_queue.arn
}

resource "aws_lambda_event_source_mapping" "sqs_trigger_2" {
  event_source_arn = aws_sqs_queue.cancel_queue.arn
  function_name    = aws_lambda_function.cancel_payment_success.arn
}



# SNS Topic for Booking
resource "aws_sns_topic" "book_sns" {
  name = var.book_sns

}
resource "aws_sqs_queue" "book_sqs_success" {
  name = var.book_sqs_success
}
data "aws_iam_policy_document" "book_sqs_policy" {
  statement {
    sid    = "SQS_Book_Policy"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.book_sqs_success.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.book_sns.arn]
    }
  }

}
resource "aws_sns_topic_subscription" "book_subs" {
  topic_arn = aws_sns_topic.book_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.book_sqs_success.arn
}
resource "aws_sqs_queue_policy" "book_policy_attach" {
  queue_url = aws_sqs_queue.book_sqs_success.id
  policy    = data.aws_iam_policy_document.book_sqs_policy.json
}

# SNS Topic for Cancel
resource "aws_sns_topic" "cancel_sns" {
  name = var.cancel_sns

}

resource "aws_sns_topic_subscription" "cancel_subs" {
  topic_arn = aws_sns_topic.cancel_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cancel_sqs_success.arn
}
resource "aws_sqs_queue" "cancel_sqs_success" {
  name = var.cancel_sqs_success
}
data "aws_iam_policy_document" "cancel_sqs_policy" {
  statement {
    sid    = "SQS_Cancel_Policy"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.cancel_sqs_success.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.cancel_sns.arn]
    }
  }

}
resource "aws_sqs_queue_policy" "cancel_policy_attach" {
  queue_url = aws_sqs_queue.cancel_sqs_success.id
  policy    = data.aws_iam_policy_document.cancel_sqs_policy.json
}

### DynamoDB Tables
resource "aws_dynamodb_table" "booking_table" {
  name           = var.admin_table
  hash_key       = var.admin_attribute1
  range_key      = var.admin_attribute2
  billing_mode   = var.billing_mode
  read_capacity  = var.rcus
  write_capacity = var.wcus
  attribute {
    name = var.admin_attribute1
    type = var.attribute_type_string
  }
  attribute {
    name = var.admin_attribute2
    type = var.attribute_type_string
  }
}



# payment lambda function for book
# IAM Role for lambda execution with
resource "aws_iam_role" "lambda_execution_db_entry" {
  name = "lambda_execution_role_db_entry"

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
resource "aws_iam_role_policy" "lambda_execution_db_entry_policy" {
  name = "CloudWatchLogsSQSPolicy"
  role = aws_iam_role.lambda_execution_db_entry.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "sqs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "dynamodb_write_policy" {
  name   = "dynamodb_write_policy"
  role   = aws_iam_role.lambda_execution_db_entry.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem"
        ],
        "Resource" : "*"
      }
    ]
}
EOF
}
#Create Lambda function for dyanamoDB entry 
resource "aws_lambda_function" "book_db_entry_function" {
  function_name = var.book_db_entry_function
  runtime       = var.runtime
  handler       = "lambda_function.lambda_handler"
  filename      = "../${var.book_db_entry_function}.zip" # Replace with your actual Lambda code
  role          = aws_iam_role.lambda_execution_db_entry.arn
  timeout       = 10
  # Other Lambda function configurations...
  environment {
    variables = {
      QUEUE_URL           = aws_sqs_queue.book_sqs_success.url
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.booking_table.name
      DYNAMODB_HASH_KEY   = aws_dynamodb_table.booking_table.hash_key
      DYNAMODB_RANGE_KEY  = aws_dynamodb_table.booking_table.range_key
    }
  }
}
resource "aws_lambda_permission" "book_entry_lambda_permission" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.book_db_entry_function.arn
  principal     = "sqs.amazonaws.com"

  source_arn = aws_sqs_queue.book_sqs_success.arn
}
resource "aws_lambda_event_source_mapping" "sqs_trigger_db_entry" {
  event_source_arn = aws_sqs_queue.book_sqs_success.arn
  function_name    = aws_lambda_function.book_db_entry_function.arn
}
