resource "aws_api_gateway_method_response" "cors_method_response" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}" 
  resource_id = "${data.terraform_remote_state.api.outputs.resource_id}" 
  http_method = aws_api_gateway_method.cors_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

