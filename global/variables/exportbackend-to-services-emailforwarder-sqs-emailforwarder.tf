resource "local_file" "services-emailforwarder-sqs-emailforwarder" {
    content  = <<EOF
data "terraform_remote_state" "variables" {
   backend = "s3"
   config = {
        key = "global/variables/variables.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${var.backendname}"
   }
}
    EOF
    filename = "../../services/emailforwarder/sqs-emailforwarder/backend-exported-from-global-variables.tf"
}
