resource "aws_api_gateway_integration_response" "cors_integration_response" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}" 
  resource_id = "${data.terraform_remote_state.api.outputs.resource_id}" 
  http_method = aws_api_gateway_method.cors_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,PUT,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
   depends_on = [aws_api_gateway_integration.cors_integration]
}
