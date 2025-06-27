resource "aws_lambda_layer_version" "email-forwarder" {
 provider    =  aws.Infrastructure
 filename   =  "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder/lambda.zip"
 layer_name =  "my_python_layer"
 compatible_runtimes = ["python3.11"]
}

