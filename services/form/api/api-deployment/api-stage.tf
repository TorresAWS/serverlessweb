resource "aws_api_gateway_stage" "example" {
  provider    =  aws.Infrastructure
  stage_name    = "${data.terraform_remote_state.variables.outputs.stage_name}" 
  rest_api_id   = "${data.terraform_remote_state.api.outputs.rest_api_id}" 
  deployment_id = aws_api_gateway_deployment.example.id
}
