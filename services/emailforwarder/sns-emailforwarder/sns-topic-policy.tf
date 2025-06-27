resource "aws_sns_topic_policy" "default" {
  provider    =  aws.Infrastructure
  arn = aws_sns_topic.emailforwarder.arn
  policy = data.aws_iam_policy_document.emailforwarder.json
  depends_on = [aws_sns_topic.emailforwarder]
}
