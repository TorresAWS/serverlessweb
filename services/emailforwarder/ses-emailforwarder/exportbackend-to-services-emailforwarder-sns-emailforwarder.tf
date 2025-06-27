resource "local_file" "exportbackend-to-services-emailforwarder-sns-emailforwarder" {
    content  = <<EOF
data "terraform_remote_state" "ses-email" {
   backend = "s3"
   config = {
        key = "services/ses-email/ses-email.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../../services/emailforwarder/sns-emailforwarder/backend-exported-from-services-emailforwarder-ses-emailforwarder.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
