terraform {
    backend "s3" {
        key = "services/lambda-form/lambda-form.tfstate"
        region = "us-east-1"
        profile  = "InfrastructureAIM"
   }
}
