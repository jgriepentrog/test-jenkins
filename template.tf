terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "griepentrog"

    workspaces {
      name = "magic_adder"
    }
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_basic_exec" {
  name = "lambda-basic-exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_basic_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

locals {
  magic_adder_lambda_filename = "build/magic_adder_lambda.zip"
}

resource "aws_lambda_function" "magic_adder_lambda" {
  filename      = local.magic_adder_lambda_filename
  function_name = "magic_adder"
  role          = aws_iam_role.lambda_basic_exec.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(local.magic_adder_lambda_filename)

  runtime     = "nodejs12.x"
  memory_size = 128
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "addmagic"
  description = "Add some magic into numbers"
}

resource "aws_api_gateway_resource" "magic_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "magic"
}

resource "aws_api_gateway_method" "magic_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.magic_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "magic_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.magic_resource.id
  http_method             = aws_api_gateway_method.magic_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.magic_adder_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.magic_adder_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.magic_get.http_method}${aws_api_gateway_resource.magic_resource.path}"
}

resource "aws_api_gateway_deployment" "magic_adder_deployment" {
  depends_on = [aws_api_gateway_integration.magic_integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"
}