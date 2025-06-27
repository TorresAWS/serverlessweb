resource "aws_cloudwatch_log_group" "lambda_log_group" {
  provider    =  aws.Infrastructure
 name              = "/aws/form/lambda-form"
 retention_in_days = 14
}
