resource "aws_api_gateway_integration_response" "mockresponse" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  status_code = "200"
  depends_on = [aws_api_gateway_integration.integrate ]
}
