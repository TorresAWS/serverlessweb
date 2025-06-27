resource "aws_api_gateway_base_path_mapping" "custom_domain_mapping" {
  provider    =  aws.Infrastructure
  domain_name =  aws_api_gateway_domain_name.domain.id 
  api_id      = "${data.terraform_remote_state.api.outputs.rest_api_id}" 
  stage_name  = aws_api_gateway_stage.example.stage_name 
  depends_on  = [aws_api_gateway_domain_name.domain, aws_api_gateway_stage.example]
}

