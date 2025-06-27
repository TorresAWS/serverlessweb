resource "aws_s3_bucket_ownership_controls" "example" {
  provider    =  aws.Infrastructure
  bucket = aws_s3_bucket.email.id
  rule {
    object_ownership = local.aws_s3_bucket_ownership_controls_rule_object_ownership
  }
}
