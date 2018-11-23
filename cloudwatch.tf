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
