resource "aws_iam_access_key" "smtp_user" {
 user = aws_iam_user.smtp_user.name
 provider    =  aws.Infrastructure
}
