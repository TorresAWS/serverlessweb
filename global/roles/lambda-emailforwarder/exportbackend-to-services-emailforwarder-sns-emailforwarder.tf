resource "local_file" "general-roles-lambda-sns" {
    content  = <<EOF
data "terraform_remote_state" "lambda-send-email-from-s3-role" {
   backend = "s3"
   config = {
        key = "global/roles/lambda-send-email-from-s3-role/lambda-send-email-from-s3-role.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}" 
   }
}
    EOF
    filename = "../../../services/emailforwarder/sns-emailforwarder/backend-exported-from-global-roles-lambda-send-email-role.tf"
}
