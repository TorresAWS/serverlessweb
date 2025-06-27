resource "aws_cloudwatch_log_group" "lambda-email-forwarder" {
 provider          =  aws.Infrastructure
 name              = "/aws/services/emailforwarder/lambda-emailforwarder" 
 retention_in_days = 14 
}
