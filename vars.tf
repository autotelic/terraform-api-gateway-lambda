variable "api_gateway_rest_api_name" {
  description = "Name of the REST API on API gateway"
}

variable "api_gateway_endpoint_method" {
  default     = "GET"
  description = "HTTP method for the API gateway proxy endpoint"
}

variable "api_gateway_deployment_stage_name" {
  default     = "development"
  description = "API gateway stage to publish endpoint on"
}

variable "lambda_function_name" {
  description = "Name of the lambda on AWS"
}

variable "lambda_handler" {
  description = "Name of the lambda handler module"
}

variable "lambda_handler_method" {
  default     = "handler"
  description = "Name of the lambda handler method"
}

variable "lambda_runtime" {
  default     = "nodejs8.10"
  description = "Node runtime for the lambda on AWS"
}

variable "lambda_zip_source_dir" {
  description = "Directory containing compiled lambda source and dependencies"
}

variable "api_gateway_lambda_iam_role" {
  description = "Name of the IAM role for lambda on AWS"
}

variable "cloudwatch_iam_role_name" {
  description = "Name of the IAM role for cloudwatch on AWS"
}
