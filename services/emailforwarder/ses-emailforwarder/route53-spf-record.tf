resource "aws_route53_record" "root_txt" {
  provider    =  aws.Domain
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"
  name    = "${aws_ses_domain_mail_from.example.mail_from_domain}"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=spf1 include:amazonses.com ~all"
  ]
}
