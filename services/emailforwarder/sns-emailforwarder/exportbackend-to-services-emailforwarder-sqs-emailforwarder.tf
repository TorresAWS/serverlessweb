resource "local_file" "exportbackend-to-services-emailforwarder-sqs-emailforwarder" {
    content  = <<EOF
data "terraform_remote_state" "sns-emailforwarder" {
   backend = "s3"
   config = {
        key = "services/emailforwarder/sns-emailforwarder/sns-emailforwarder.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../../services/emailforwarder/sqs-emailforwarder/backend-exported-from-services-emailforwarder-sns-emailforwarder.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
