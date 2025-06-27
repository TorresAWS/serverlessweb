data "aws_iam_policy_document" "emailforwarder" {
  policy_id = "__default_policy_ID"
  provider    =  aws.Infrastructure
 statement {
    actions = [
      "SNS:Publish",
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
       "arn:aws:sns:us-east-1:211125559094:emailforwarder"
    ]
  }
}
