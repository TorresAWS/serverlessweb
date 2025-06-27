resource "local_file" "general-roles-lambda-send-email-from-api-role" {
    content  = <<EOF
data "terraform_remote_state" "lambda-send-email-from-api-role" {
   backend = "s3"
   config = {
        key = "global/roles/lambda-send-email-from-api-role/lambda-send-email-from-api-role.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}" 
   }
}
    EOF
    filename = "../../../services/form/lambda-form/backend-exported-from-global-roles-lambda-send-email-from-api-role.tf"
}
