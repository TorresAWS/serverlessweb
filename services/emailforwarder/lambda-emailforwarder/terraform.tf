terraform {
    backend "s3" {
        key = "services/lambda-email-forwarder/lambda-email-forwarder.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
   }
}
