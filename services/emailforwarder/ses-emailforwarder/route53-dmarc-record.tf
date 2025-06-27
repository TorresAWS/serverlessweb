resource "aws_route53_record" "dmarc_txt" {
  provider    =  aws.Domain
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"
  name    = "_dmarc.${data.terraform_remote_state.variables.outputs.domain}"
  type    = "TXT"
  ttl     = "300"
  records = [
   "v=DMARC1; p=none;"
  ]
}
