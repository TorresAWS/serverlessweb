resource "aws_ses_configuration_set" "ses_config" {
  provider    =  aws.Infrastructure
  name = "config_ses"
  reputation_metrics_enabled = true
}
