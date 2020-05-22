
## var.bucket_name = bucket Function Name
resource "aws_cloudwatch_event_rule" "s3bucket" {
  name        = "Capture-bucket-file-upload"
  description = "Capture putting a Document in the s3 bucket"
  is_enabled = "true"
  event_pattern = <<EOF
  {
      "source": [
          "aws.s3"
      ],
      "detail-type": [
          "AWS API Call via CloudTrail"
      ],
      "detail": {
          "eventSource": [
              "s3.amazonaws.com"
          ],
          "eventName": [
              "PutObject"
          ],
          "requestParameters": {
              "bucketName": ["${var.bucket_name}"]
          }
      }
  }
  EOF
}
resource "aws_cloudwatch_event_target" "sns" {
  target_id = "SendtoSNS"
  rule      = "${aws_cloudwatch_event_rule.s3bucket}"
  arn       = "arn:aws:sns:${var.region}:${var.account_id}:${var.sns_name}"
}
