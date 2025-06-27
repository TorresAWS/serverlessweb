resource "local_file" "exportbackend-to-services-emailforwarder-ses-emailforwarder" {
    content  = <<EOF
data "terraform_remote_state" "ses" {
   backend = "s3"
   config = {
        key = "services/ses/ses.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../services/emailforwarder/sns-emailforwarder/backend-exported-from-services-ses.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
