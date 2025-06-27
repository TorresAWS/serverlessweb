resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "until curl --silent ${aws_api_gateway_domain_name.domain.domain_name} > /dev/null ;do sleep 1; done "
  }
 depends_on = [aws_route53_record.domain]
}
