resource "aws_s3_bucket_acl" "example" {
  provider    =  aws.Infrastructure
  depends_on  = [aws_s3_bucket_ownership_controls.example]
  bucket      = aws_s3_bucket.email.id
  acl         = local.aws_s3_bucket_acl_acl
}
