resource "aws_ses_domain_mail_from" "example" {
  provider    =  aws.Infrastructure
  domain           =  "${aws_ses_domain_identity.domain_identity.domain}"
  mail_from_domain = "mail.${aws_ses_domain_identity.domain_identity.domain}"
}
