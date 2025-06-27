data "aws_iam_policy_document" "ses_send_templated_email_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = [
         "${data.terraform_remote_state.ses.outputs.aws-ses-email-identity-semplates-email-identity-arn}","arn:aws:ses:${data.terraform_remote_state.variables.outputs.region}:${data.terraform_remote_state.variables.outputs.account_id}:identity/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
