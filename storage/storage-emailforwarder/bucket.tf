resource "aws_s3_bucket" "email" {
  provider    =  aws.Infrastructure
  bucket      = "${data.terraform_remote_state.variables.outputs.ses-bucket-name}" 
  force_destroy =local.aws_s3_bucket_force_destroy
  timeouts {
    create = local.aws_s3_bucket_timeouts
  }
}




