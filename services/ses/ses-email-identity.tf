resource "aws_ses_email_identity" "semplates_email_identity" {
 provider    =  aws.Infrastructure
 email = "${data.terraform_remote_state.variables.outputs.ses-email}"
}
