resource "aws_iam_role" "lambda-email-forwarder" {
  provider    =  aws.Infrastructure
  name   =  "${data.terraform_remote_state.variables.outputs.lambda_role_name}" 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": "AllowLambdaAssumeRole"
   }
 ]
}
EOF
}



