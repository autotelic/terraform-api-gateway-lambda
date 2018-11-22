provider "aws" {
  region = "us-west-2"
}

module "http_lambda" {
  source                            = "../.."
  api_gateway_rest_api_name         = "my_lambda"
  api_gateway_endpoint_method       = "GET"
  api_gateway_deployment_stage_name = "development"
  lambda_function_name              = "lambda_func"
  lambda_handler                    = "lambdaClass"
  lambda_handler_method             = "handler"
  lambda_zip_source_dir             = "../build"
  api_gateway_lambda_iam_role       = "http_lambda_example_iam_role"
}

output "invoke_url" {
  value = "${module.http_lambda.invoke_url}"
}
