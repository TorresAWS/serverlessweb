resource "local_file" "exportbackend-to-services-form-api-deployment" {
    content  = <<EOF
data "terraform_remote_state" "certs" {
   backend = "s3"
   config = {
        key = "vpcs/certs/certs.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../services/form/api/api-deployment/backend-exported-from-vpcs-certs.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
