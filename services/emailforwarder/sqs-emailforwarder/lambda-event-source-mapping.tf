resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  provider         = aws.Infrastructure
  event_source_arn = aws_sqs_queue.emailforwarder.arn 
  enabled          = true
  function_name    =  "${data.terraform_remote_state.lambda-emailforwarder.outputs.aws_lambda_function-email-forwarder-arn}" 
  batch_size       = 1
}
