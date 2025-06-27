resource "aws_iam_policy" "Python-lambda-email-forwarder" {
 provider     =  aws.Infrastructure
 name         =  "${data.terraform_remote_state.variables.outputs.lambda_policy_role_name}" 
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role" 
 policy       = data.aws_iam_policy_document.lambda-email-forwarder.json
}
