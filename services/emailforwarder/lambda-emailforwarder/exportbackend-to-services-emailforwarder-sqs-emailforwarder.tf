resource "local_file" "exportbackend-to-sqs-emailforwarder" {
    content  = <<EOF
data "terraform_remote_state" "lambda-emailforwarder" {
   backend = "s3"
   config = {
        key = "services/lambda-email-forwarder/lambda-email-forwarder.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../../services/emailforwarder/sqs-emailforwarder/backend-exported-from-services-emailforwarder-lambda-emailforwarder.tf"
    depends_on = [data.terraform_remote_state.variables ]
}

