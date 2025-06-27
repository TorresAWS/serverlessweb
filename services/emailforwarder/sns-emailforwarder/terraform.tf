terraform {
    backend "s3" {
        key = "services/emailforwarder/sns-emailforwarder/sns-emailforwarder.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
   }
}
