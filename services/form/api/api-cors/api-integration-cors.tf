resource "aws_api_gateway_integration" "cors_integration" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}" 
  resource_id = "${data.terraform_remote_state.api.outputs.resource_id}" 
  http_method = aws_api_gateway_method.cors_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
