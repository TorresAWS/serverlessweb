#output "account_id" {
#  value = data.aws_caller_identity.current.account_id
#}
#output "region" {
#  value = data.aws_region.current.name
#}
#output "account_id_variable" {
#  value = "${data.terraform_remote_state.variables.outputs.account_id}" 
#}
#output "region_variable" {
#  value = "${data.terraform_remote_state.variables.outputs.region}"
#}
output "aws_s3_bucket_email_bucket" {
  description = ""
  value       =  aws_s3_bucket.email.bucket
}
output "aws_s3_bucket_email_arn" {
  description = ""
  value       =   aws_s3_bucket.email.arn
}
