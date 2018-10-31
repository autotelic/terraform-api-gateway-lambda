data "aws_region" "current" {}

provider "archive" {}

data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.api_gateway_rest_api_name}"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "{proxy+}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "${var.api_gateway_endpoint_method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  depends_on              = ["aws_api_gateway_method.method"]
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "${var.api_gateway_endpoint_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.lambda.function_name}/invocations"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "CarrierIntegrationResponse" {
  depends_on = [
    "aws_api_gateway_method.method",
    "aws_api_gateway_integration.integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    "aws_api_gateway_method.method",
    "aws_api_gateway_integration.integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${var.api_gateway_deployment_stage_name}"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${data.archive_file.lambda_zip.output_path}"
  function_name    = "${var.lambda_function_name}"
  role             = "${aws_iam_role.role.arn}"
  handler          = "${var.lambda_handler}${var.lambda_handler_method}"
  runtime          = "${var.lambda_runtime}"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "./${var.lambda_handler}.zip"
  source_dir  = "${var.lambda_zip_source_dir}"
}

# IAM
resource "aws_iam_role" "role" {
  name = "${var.api_gateway_lambda_iam_role}"

  assume_role_policy = <<POLICY
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
POLICY
}
