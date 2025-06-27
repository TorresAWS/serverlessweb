resource "local_file" "exportbackend-to-global-roles-lambda-form" {
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
    filename = "../../global/roles/lambda-form/backend-exported-from-global-variables.tf"
}
