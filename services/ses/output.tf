output "aws-ses-email-identity-semplates-email-identity-arn" {
  description = ""
  value       =  aws_ses_email_identity.semplates_email_identity.arn 
}

#output "aws-ses-template-semplates-demo-template-arn" {
#  description = ""
#  value       = aws_ses_template.semplates_demo_template.arn 
#}

output "aws_ses_email_identity_semplates_email_identity_email" {
  description = ""
  value       =  aws_ses_email_identity.semplates_email_identity.email
}


