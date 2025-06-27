resource "aws_lambda_alias" "PythonSesEmailSender" {
  provider    =  aws.Infrastructure
 name             = "dev"
 function_name    = aws_lambda_function.PythonSesEmailSender.function_name
 function_version = aws_lambda_function.PythonSesEmailSender.version
}

