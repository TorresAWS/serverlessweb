resource "aws_api_gateway_method" "proxy" {
  provider    =  aws.Infrastructure
  rest_api_id   = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id   = "${data.terraform_remote_state.api.outputs.resource_id}"
  http_method   = "PUT"
  authorization = "NONE"
}
