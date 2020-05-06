# var.region
# var.account_id
# var.bucket_name
# var.bucket_id
## comment kms_master_key_id if u are getting an error, we can try this later

resource "aws_sns_topic" "topic" {
    name = "s3-event-notification-topic"
    policy = <<-POLICY
    {
        "Version":"2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            }
            "Action": "SNS:Publish",
            "Resource": "arn:aws:sns:${var.region}:${var.account_id}:s3-event-notification-topic",
            "Condition":{
                "StringEquals": {"aws:SourceAccount": "${var.account_id}"},
                "StringLike":{"aws:SourceArn":"${var.bucket_name}"}
            }
        }]
    }
    POLICY
}

#####
# SQS with redrive policy 
# redrive policy : https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-configure-dead-letter-queue.html
#
resource "aws_sqs_queue" "queue" {
    name = "s3-event-notification-queue"
    kms_master_key_id = "${aws_kms_key.sqs.key_id}"
    visibility_timeout_seconds = 300
    redrive_policy = <<-POLICY
    {
        "deadLetterTargetArn": "{aws_sqs_queue.deadletter.arn}",
        "maxReceiveCount": "5"
    }
    POLICY 

    policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Id": "sqspolicy",
        "Statement": [
            {
                "Sid": "First",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "sqs:SendMessage",
                "Resource": "arn:aws:sns:${var.region}:${var.account_id}:s3-event-notification-queue",
                "Condition": {
                    "ArnEquals": {
                        "aws:SourceArn": "${aws_sns_topic.topic.arn}"
                    }
                } 
            }  
        ]
    }
    POLICY
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.topic.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sns_topic.queue.arn}"
}
## bubket = bucket.id - not sure ifn this is the name or just id.try this later
resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = "${var.bucket_id}"
    topic {
        topic_arn     = "${aws_sns_topic.topic.arn}"
        events        = ["s3:ObjectCreated:*"]
    }
}


