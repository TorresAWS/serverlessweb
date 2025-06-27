resource "aws_api_gateway_integration" "integrate" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}" 
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${data.terraform_remote_state.lambda-general-json.outputs.aws-lambda-function-PythonSesEmailSender-invoke-arn}"
}
