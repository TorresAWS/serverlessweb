resource "aws_sqs_queue" "emailforwarder" {
  name = "emailforwarder"
  redrive_policy  = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.emailforwarder-dl.arn}\",\"maxReceiveCount\":5}"
  provider    =  aws.Infrastructure
  visibility_timeout_seconds = 300
  message_retention_seconds  = 345600
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
}
