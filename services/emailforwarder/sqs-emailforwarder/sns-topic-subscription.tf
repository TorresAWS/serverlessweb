resource "aws_sns_topic_subscription" "example_topic_subscription" {
  provider  = aws.Infrastructure
  topic_arn = "${data.terraform_remote_state.sns-emailforwarder.outputs.aws-sns-topic-emailforwarder-arn}"  
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.emailforwarder.arn 
}
