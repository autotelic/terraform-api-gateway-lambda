variable "api_gateway_rest_api_name" {}

variable "api_gateway_endpoint_method" {
  default = "GET"
}

variable "api_gateway_deployment_stage_name" {
  default = "development"
}

variable "lambda_function_name" {}
variable "lambda_handler" {}
variable "lambda_handler_method" {
  default = "handler"
}
variable "lambda_runtime" {
  default = "nodejs8.10"
}
variable "lambda_zip_source_dir" {}

variable "api_gateway_lambda_iam_role" {
  default = "api_gateway_lambda_iam_role"
}
