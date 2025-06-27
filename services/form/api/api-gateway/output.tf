output "rest_api_id" {
  description = ""
  value = "${aws_api_gateway_rest_api.PythonSesEmailSender.id}"
}

output "resource_id" {
  description = ""
  value = "${aws_api_gateway_resource.proxy.id}"
}



