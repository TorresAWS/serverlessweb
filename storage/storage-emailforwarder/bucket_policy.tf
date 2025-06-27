resource "aws_s3_bucket_policy" "email" {
  provider    =  aws.Infrastructure
  bucket = aws_s3_bucket.email.id 
  policy = <<EOF
{ 
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSESPuts",
      "Effect": "Allow",
      "Principal": {
        "Service": "ses.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.email.arn}/email/*",
      "Condition": {
        "StringEquals": {
        "aws:Referer": "${data.terraform_remote_state.variables.outputs.account_id}"
        }
      }
    }
  ]   
}     
EOF   
}
