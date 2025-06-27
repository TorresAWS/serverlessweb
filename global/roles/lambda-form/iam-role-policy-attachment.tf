resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 provider    =  aws.Infrastructure
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}
