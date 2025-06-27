resource "aws_lambda_permission" "email" {
 provider    =  aws.Infrastructure
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.email-forwarder.function_name
  principal      = "ses.amazonaws.com"
  source_account = "${data.terraform_remote_state.variables.outputs.account_id}" 
}





