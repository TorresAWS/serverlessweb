resource "aws_lambda_alias" "email-forwarder" {
  provider    =  aws.Infrastructure
 name             = "dev"
 function_name    = aws_lambda_function.email-forwarder.function_name
 function_version = aws_lambda_function.email-forwarder.version
}
