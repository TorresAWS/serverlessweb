terraform {
    backend "s3" {
        key = "services/smtp/smtp.tfstate"
        region = "us-east-1"
        profile  = "InfrastructureAIM"
   }
}
