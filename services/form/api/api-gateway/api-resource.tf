resource "aws_api_gateway_resource" "proxy" {
  provider    =  aws.Infrastructure
  rest_api_id = "${aws_api_gateway_rest_api.PythonSesEmailSender.id}"
  parent_id   = "${aws_api_gateway_rest_api.PythonSesEmailSender.root_resource_id}"
  path_part   = "${data.terraform_remote_state.variables.outputs.api_path_name}"
}
