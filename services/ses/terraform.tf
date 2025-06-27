terraform {
    backend "s3" {
        key = "services/ses/ses.tfstate"
        region = "us-east-1"
        profile  = "InfrastructureAIM"
   }
}
