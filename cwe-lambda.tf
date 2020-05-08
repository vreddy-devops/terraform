
## var.lambda_name = Lambda Function Name

resource "aws_cloudwatch_event_rule" "lambda" {
  name        = "lambda cf event"
  description = "Schedule trigger for lambda execution"
  schedule_expression = "cron(0 * * * ? *)"
  is_enabled = "true"
}
resource "aws_cloudwatch_event_target" "lambda" {
  target_id = "${var.lambda_name}"
  rule      = "${aws_cloudwatch_event_rule.lambda.name}"
  arn       = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda_name}"
}
