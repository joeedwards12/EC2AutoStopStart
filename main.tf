terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21"
    }
  }
  required_version = ">= 1.5.6"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

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

resource "aws_iam_policy" "lambda_execution_policy" {
  name = "lambda_execution_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_lambda_function" "start_instances" {
  function_name    = "start_instances"
  handler          = "start.lambda_handler"
  runtime          = "python3.10"
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = "start.zip"
  source_code_hash = filebase64sha256("start.zip")
  timeout          = 20
}

resource "aws_lambda_function" "stop_instances" {
  function_name    = "stop_instances"
  handler          = "stop.lambda_handler"
  runtime          = "python3.10"
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = "stop.zip"
  source_code_hash = filebase64sha256("stop.zip")
  timeout          = 20
}

resource "aws_cloudwatch_event_rule" "start_instances_rule" {
  name        = "start_instances_rule"
  description = "Schedule to start instances at 8 am on weekdays"

  schedule_expression = "cron(0 7 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "start_instances_target" {
  rule      = aws_cloudwatch_event_rule.start_instances_rule.name
  target_id = "start_instances_target"
  arn       = aws_lambda_function.start_instances.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_instances_rule.arn
}

resource "aws_cloudwatch_event_rule" "stop_instances_rule" {
  name        = "stop_instances_rule"
  description = "Schedule to stop instances at 7 pm on weekdays"

  schedule_expression = "cron(0 18 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "stop_instances_target" {
  rule      = aws_cloudwatch_event_rule.stop_instances_rule.name
  target_id = "stop_instances_target"
  arn       = aws_lambda_function.stop_instances.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instances_rule.arn
}
