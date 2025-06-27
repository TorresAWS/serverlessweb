resource "aws_ses_domain_identity" "domain_identity" {
  provider    =  aws.Infrastructure
  domain = "${data.terraform_remote_state.variables.outputs.domain}"
}
