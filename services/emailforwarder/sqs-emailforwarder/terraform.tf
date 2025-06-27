terraform {
    backend "s3" {
        key = "services/emailforwarder/sqs-emailforwarder/sqs-emailforwarder.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
   }
}
