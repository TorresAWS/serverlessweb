resource "aws_lambda_layer_version" "PythonSesEmailSender" {
 provider    =  aws.Infrastructure
 filename   = "${path.module}/../../../files/form/lambda.zip"
 layer_name = "my_python_layer"
 compatible_runtimes = ["python3.11"]
}
