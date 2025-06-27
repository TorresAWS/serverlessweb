terraform {
    backend "s3" {
        key = "storage/storage-ses-email/storage-ses-email.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
   }
}
