data "terraform_remote_state" "general-roles-lambda-sqs" {
   backend = "s3"
   config = {
        key = "global/roles/lambda-sqs/lambda-sqs.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "tfstate05122025" 
   }
}
