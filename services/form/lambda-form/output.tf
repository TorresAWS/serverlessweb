output "aws-lambda-function-PythonSesEmailSender-invoke-arn" {
  description = "Website URL (HTTP) http://"
  value       = aws_lambda_function.PythonSesEmailSender.invoke_arn 
}

output "aws-lambda-function-PythonSesEmailSender-function-name" {
  description = "Website URL (HTTP) http://"
  value       = aws_lambda_function.PythonSesEmailSender.function_name 
}
