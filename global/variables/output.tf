output "domain" {
  description = ""
  value       = var.domain  
}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "region" {
  value = data.aws_region.current.region
}
output "backendname" {
  value = var.backendname
}
output "ses-bucket-name" {
  description = ""
  value       = var.ses-bucket-name
}
output "ses-email" {
  description = ""
  value       = var.ses-email
}
output "path_to_lambda" {
  description = ""
  value       = var.path_to_lambda
}
output "path_to_website" {
  description = ""
  value       = var.path_to_website
}
output "lambda_role_name" {
  description = ""
  value       = var.lambda_role_name
}
output "lambda_policy_role_name" {
  description = ""
  value       = var.lambda_policy_role_name
}
output "lambda_send_email_from_api_role_name" {
  description = ""
  value       = var.lambda_send_email_from_api_role_name
}
output "lambda_send_email_from_api_role_policy_name" {
  description = ""
  value       = var.lambda_send_email_from_api_role_policy_name
}
output "api_domain" {
  description = ""
  value       = var.api_domain
}
output "api_path_name" {
  description = ""
  value       = var.api_path_name
}

output "subdomains" {
  description = ""
  value       = var.subdomains
}

output "stage_name" {
  description = ""
  value       = var.stage_name
}
output "email_usernames" {
  description = ""
  value       = var.email_usernames
}
output "lambda_sqs_role_name" {
  description = ""
  value       = var.lambda_sqs_role_name
}
output "lambda_sqs_policy_role_name" {
  description = ""
  value       = var.lambda_sqs_policy_role_name
}
