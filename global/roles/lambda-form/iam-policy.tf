resource "aws_iam_policy" "iam_policy_for_lambda" {
 provider    =  aws.Infrastructure
 name         = "${data.terraform_remote_state.variables.outputs.lambda_send_email_from_api_role_policy_name}" 
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy      = data.aws_iam_policy_document.ses_send_templated_email_policy.json
}
