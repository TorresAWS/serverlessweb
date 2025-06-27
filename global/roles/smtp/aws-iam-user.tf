resource "aws_iam_user" "smtp_user" {
  name = "smtp_user"
  provider    =  aws.Infrastructure
}
