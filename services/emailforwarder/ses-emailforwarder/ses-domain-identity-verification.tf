resource "aws_ses_domain_identity_verification" "domain_identity_verification" {
  provider    =  aws.Infrastructure
  domain = aws_ses_domain_identity.domain_identity.id
  depends_on = [aws_route53_record.amazonses_dkim_record]
}
