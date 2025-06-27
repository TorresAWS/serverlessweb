data "aws_iam_policy_document" "lambda-email-forwarder" {
  provider    =  aws.Infrastructure
  statement {
    sid = "AllowLambdaToSendEmails" 
    effect = "Allow"
    actions = [
 	"s3:GetObject",
        "s3:ListBucket",
        "ses:SendRawEmail",
    ]
    resources = [
   "arn:aws:s3:::${data.terraform_remote_state.storage-ses-email.outputs.aws_s3_bucket_email_bucket}/*",     "arn:aws:s3:::${data.terraform_remote_state.storage-ses-email.outputs.aws_s3_bucket_email_bucket}", "arn:aws:ses:${data.terraform_remote_state.variables.outputs.region}:${data.terraform_remote_state.variables.outputs.account_id}:identity/*"
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
  statement {
    effect = "Allow"
    actions = [
       "sqs:*"
    ]
    resources = ["*"]
  }
}
