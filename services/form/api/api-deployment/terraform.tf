terraform {
    backend "s3" {
        key = "services/api-deployment/api-deployment.tfstate"
        region = "us-east-1"
        profile  = "InfrastructureAIM"
   }
}
