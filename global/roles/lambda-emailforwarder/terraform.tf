terraform {
    backend "s3" {
        key = "global/roles/lambda-send-email-from-s3-role/lambda-send-email-from-s3-role.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
    }
}
