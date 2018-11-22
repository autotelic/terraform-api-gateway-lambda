# terraform-api-gateway-lambda

Terraform module to create an AWS lambda fronted by an API gateway method

## Usage

```hcl

provider "aws" {
  region = "us-west-2"
}

module "http_lambda" {
  source = "github.com/autotelic/terraform-api-gateway-lambda"
  api_gateway_rest_api_name = "my_lambda"
  api_gateway_endpoint_method = "POST"
  api_gateway_deployment_stage_name = "development"
  lambda_function_name = "lambda_func"
  lambda_handler = "handlerClassName"
  lambda_handler_method = "handler"
  lambda_zip_source_dir = "../build"
}

```