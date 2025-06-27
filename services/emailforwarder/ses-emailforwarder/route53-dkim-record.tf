resource "aws_route53_record" "amazonses_dkim_record" {
  provider    =  aws.Domain
  count   = 3
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"
  name    = "${aws_ses_domain_dkim.dkim_identity.dkim_tokens[count.index]}._domainkey.${aws_ses_domain_identity.domain_identity.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_ses_domain_dkim.dkim_identity.dkim_tokens[count.index]}.dkim.amazonses.com"]
}
