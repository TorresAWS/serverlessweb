terraform {
    backend "s3" {
        key = "services/ses-email/ses-email.tfstate"
        region = "us-east-1"
        profile  = "InfrastructureAIM"
   }
}
