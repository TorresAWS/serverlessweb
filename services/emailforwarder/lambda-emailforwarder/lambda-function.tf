resource "aws_lambda_function" "email-forwarder" {
 provider    =  aws.Infrastructure
 filename      = "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder/lambda.zip"
 function_name =  "python-lambda-email-forwarder"
 role          = "${data.terraform_remote_state.lambda-send-email-from-s3-role.outputs.arn}" 
 handler       = "main.lambda_handler"
 timeout       = 30
 runtime       = "python3.12"
 source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256 
 environment {
    variables = {
      MailS3Bucket  = "${data.terraform_remote_state.storage-ses-email.outputs.aws_s3_bucket_email_bucket}" 
      MailS3Prefix  = "email"
      MailSender    = "info@${data.terraform_remote_state.variables.outputs.domain}" 
      MailRecipient =  "${data.terraform_remote_state.variables.outputs.ses-email}"
      Region        = "${data.terraform_remote_state.variables.outputs.region}" 
    }
  }
}





