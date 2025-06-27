resource "local_file" "exportbackend-to-form-cors" {
    content  = <<EOF
data "terraform_remote_state" "api" {
   backend = "s3"
   config = {
        key = "services/form/api/api.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../../../services/form/api/api-cors/backend-exported-from-services-form-api.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
