# What AWS services does this set up?

- Lambda
- API Gateway
- Lambda logs
- CloudWatch for API Gateway logs
- all necessary roles for this execution to work


## How to use in my project?

Create a folder `infrastructure` in the top level of your project, which should be parallel to the `build` folder of your source code for the Lamda function.
In this example we have set up all the services in region `us-west-2`, but this can be changed to whichever region is closest to you.

To use this module, add two files in your folder `infrastructure`: 
1. `main.tf`
2. `config.tf

**main.tf** 

This file sets up all your variables that the module expects. 
The names below are all examples and should be replaced with names related to your project.
Keep the path shown at `source` as is - it references this `terraform-api-gateway-lambda` module to use with your variables.

```hcl

provider "aws" {
  region = "us-west-2"
}

module "http_lambda" {
  source                            = "github.com/autotelic/terraform-api-gateway-lambda"
  api_gateway_rest_api_name         = "my-name-api-gateway"
  api_gateway_endpoint_method       = "POST"
  api_gateway_deployment_stage_name = "development"
  lambda_function_name              = "my-name-lambda"
  lambda_handler                    = "lambdaHandlerName"
  lambda_handler_method             = "handler"
  lambda_zip_source_dir             = "../build"
  api_gateway_lambda_iam_role       = "my-name-lambda-role"
  cloudwatch_iam_role_name          = "api-gateway-cloudwatch-my-name"
}

output "invoke_url" {
  value = "${module.http_lambda.invoke_url}"
}

```  


**config.tf**  

This file sets up a bucket to store your .tfstate so multiple users can access it and run `terraform` commands against it.
Terraform detects the `config.tf` file and therefore does not store the .tfstate on your local machine, but pushes it to an s3 bucket.
The example bucket name `my-name-terraform-state` should be changed to a specific name for your project.
__Keep in mind, bucket names are globally unique, so if your name already exists, try a different one.__


```
terraform {
  backend "s3" {
    bucket = "my-name-terraform-state"
    key    = ".terraform/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config {
    bucket = "my-name-terraform-state"
    key    = ".terraform/terraform.tfstate"
    region = "us-west-2"
  }
}
```

With this set up, run
- `aws-vault exec <YOUR-AWS-ACCOUNT-NAME> -- terraform init`
- `aws-vault exec <YOUR-AWS-ACCOUNT-NAME> -- terraform plan` __// optional, to see what will be created__
- `aws-vault exec <YOUR-AWS-ACCOUNT-NAME> -- terraform apply`

After all resources have been created, you should see your API Gateway URL echoed back to you in the console.


Need more info on how to set up aws-vault? Click [here](https://github.com/99designs/aws-vault)
