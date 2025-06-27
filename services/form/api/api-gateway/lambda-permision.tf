resource "aws_lambda_permission" "PythonSesEmailSender" {
 provider    =  aws.Infrastructure
 statement_id  = "AllowAPIGatewayInvoke"
 action        = "lambda:InvokeFunction"
 function_name = "${data.terraform_remote_state.lambda-general-json.outputs.aws-lambda-function-PythonSesEmailSender-function-name}"
 principal     = "apigateway.amazonaws.com"
 # The /*/* portion grants access from any method on any resource
 # within the API Gateway "REST API".
 source_arn = "${aws_api_gateway_rest_api.PythonSesEmailSender.execution_arn}/*/*"
 
}
