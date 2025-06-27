resource "aws_ses_active_receipt_rule_set" "primary" {
  provider    =  aws.Infrastructure
  rule_set_name = aws_ses_receipt_rule_set.primary.rule_set_name
}
