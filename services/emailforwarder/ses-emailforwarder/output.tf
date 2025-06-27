output "aws_ses_receipt_rule_set_primary_rule_set_name" {
  description = ""
  value       =  aws_ses_receipt_rule_set.primary.rule_set_name 
}
output "mail-from" {
  description = ""
  value       =   aws_ses_domain_mail_from.example.mail_from_domain 
}
output "domain" {
  description = ""
  value       =    aws_ses_domain_identity.domain_identity.domain 
}
