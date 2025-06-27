resource "aws_lambda_function" "PythonSesEmailSender" {
 provider    =  aws.Infrastructure
 filename      = "${path.module}/../../../files/form/lambda.zip"
 function_name = "python-lambda-general-json"
 role          = "${data.terraform_remote_state.lambda-send-email-from-api-role.outputs.arn}" 
 handler       = "main.lambda_handler"
 timeout       = 60
  runtime       = "python3.11"
  environment {
    variables = {
      SES_REGION = "${data.terraform_remote_state.variables.outputs.region}" 
      MailSender    = "${data.terraform_remote_state.variables.outputs.ses-email}"
      MailRecipient = "info@${data.terraform_remote_state.variables.outputs.domain}" 
    }
  }
}





