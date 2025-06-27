terraform {
    backend "s3" {
        key = "services/form/api-cors/api-cors.tfstate"
        region = "us-east-1"
        profile  = "InfrastructureAIM"
   }
}
