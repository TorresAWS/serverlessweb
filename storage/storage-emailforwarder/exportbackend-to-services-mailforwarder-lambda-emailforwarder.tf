resource "local_file" "exportbackend-to-services-mailforwarder-lambda-emailforwarder" {
    content  = <<EOF
data "terraform_remote_state" "storage-ses-email" {
   backend = "s3"
   config = {
        key = "storage/storage-ses-email/storage-ses-email.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../services/emailforwarder/lambda-emailforwarder/backend-exported-from-storage-storage-emailforwarder.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
