resource "aws_ses_domain_dkim" "dkim_identity" {
  provider    =  aws.Infrastructure
  domain = aws_ses_domain_identity.domain_identity.domain
}
