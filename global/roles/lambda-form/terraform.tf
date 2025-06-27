terraform {
    backend "s3" {
        key = "global/roles/lambda-send-email-from-api-role/lambda-send-email-from-api-role.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
    }
}
