resource "aws_route53_record" "email" {
  provider    =  aws.Domain
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}" 
  name    = "${data.terraform_remote_state.variables.outputs.domain}" 
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${data.terraform_remote_state.variables.outputs.region}.amazonaws.com"]
}


