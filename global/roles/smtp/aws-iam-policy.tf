resource "aws_iam_policy" "ses_sender" {
 provider    =  aws.Infrastructure
  name        = "ses_sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

