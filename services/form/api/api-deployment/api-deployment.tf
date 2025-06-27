resource "aws_api_gateway_deployment" "example" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
}



