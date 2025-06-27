resource "aws_ses_receipt_rule" "email" {
 provider    =  aws.Infrastructure
  name          = "email-sns-forwarder" 
  rule_set_name = "${data.terraform_remote_state.ses-email.outputs.aws_ses_receipt_rule_set_primary_rule_set_name}"
  recipients    = [for username in data.terraform_remote_state.variables.outputs.email_usernames : "${username}@${data.terraform_remote_state.variables.outputs.domain}"]
  enabled       = true 
  scan_enabled  = false 

  s3_action {
    position          = 1
    bucket_name       = "${data.terraform_remote_state.storage-ses-email.outputs.aws_s3_bucket_email_bucket}" 
    object_key_prefix = "email/"
  }
  sns_action {
    position  = 2
    topic_arn = aws_sns_topic.emailforwarder.arn  
  }
  depends_on = [aws_sns_topic.emailforwarder]
}
