resource "aws_route53_record" "domain" {
  name    = aws_api_gateway_domain_name.domain.domain_name
  type    = "A"
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}" 

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.domain.cloudfront_zone_id
  }
}



