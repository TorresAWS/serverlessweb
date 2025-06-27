resource "aws_lambda_permission" "with_sqs" {
  statement_id  = "AllowExecutionFromSQS"
  provider      =  aws.Infrastructure
  action        = "lambda:InvokeFunction"
  function_name = "${data.terraform_remote_state.lambda-emailforwarder.outputs.aws_lambda_function-email-forwarder-function_name}" 
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.emailforwarder.arn
}
