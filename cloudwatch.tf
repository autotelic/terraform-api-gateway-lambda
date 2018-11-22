# Alerts Lambda
resource "aws_lambda_permission" "cloudwatch_alerts_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloudwatch_alerts_lambda.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.cloudwatch.arn}"
}

resource "aws_lambda_function" "cloudwatch_alerts_lambda" {
  filename         = "${data.archive_file.cloudwatch_alerts_lambda_zip.output_path}"
  function_name    = "cloudwatch_alerts"
  role             = "${aws_iam_role.role.arn}"
  handler          = "cloudwatchSlackAlerts.handler"
  runtime          = "nodejs8.10"
  source_code_hash = "${data.archive_file.cloudwatch_alerts_lambda_zip.output_base64sha256}"

  environment {
    variables = {
      UNENCRYPTED_HOOK_URL = ""
    }
  }
}

data "archive_file" "cloudwatch_alerts_lambda_zip" {
  type        = "zip"
  output_path = "./cloudwatchSlackAlerts.zip"
  source_dir  = "../cloudwatch_alerts"
}

# SNS
resource "aws_sns_topic" "cloudwatch" {
  name = "cloudwatch_alarms"
}
resource "aws_sns_topic_subscription" "cloudwatch" {
  topic_arn = "${aws_sns_topic.cloudwatch.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.cloudwatch_alerts_lambda.arn}"
}

# IAM
resource "aws_iam_role_policy" "cloudwatch_logs" {
  role = "${aws_iam_role.role.name}"

  policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["logs:*"],
      "Resource": ["*"]
    }
  ]
}
EOF
}
