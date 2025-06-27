resource "aws_api_gateway_domain_name" "domain" {
  provider    =  aws.Infrastructure
  certificate_arn =  "${data.terraform_remote_state.certs.outputs.aws-acm-certificate-domain-arn}" 
  domain_name     = "${data.terraform_remote_state.variables.outputs.api_domain}.${data.terraform_remote_state.variables.outputs.domain}"
}
