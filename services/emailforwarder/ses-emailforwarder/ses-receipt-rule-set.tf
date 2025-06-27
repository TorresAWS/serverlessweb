resource "aws_ses_receipt_rule_set" "primary" {
  provider    =  aws.Infrastructure
  rule_set_name = "primary"
}
