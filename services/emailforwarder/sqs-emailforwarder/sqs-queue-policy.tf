resource "aws_sqs_queue_policy" "emailforwarder" {
    provider    =  aws.Infrastructure
    queue_url = "${aws_sqs_queue.emailforwarder.id}"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.emailforwarder.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${data.terraform_remote_state.sns-emailforwarder.outputs.aws-sns-topic-emailforwarder-arn}" 
        }
      }
    }
  ]
}
POLICY
}
