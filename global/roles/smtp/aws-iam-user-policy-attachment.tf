resource "aws_iam_user_policy_attachment" "test-attach" {
 provider    =  aws.Infrastructure
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}
