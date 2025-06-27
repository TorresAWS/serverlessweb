resource "aws_api_gateway_rest_api" "PythonSesEmailSender" {
 provider    =  aws.Infrastructure
 name        = "my_api_gateway"
 description = "API Gateway for form"
}
