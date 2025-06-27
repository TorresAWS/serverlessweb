resource "local_file" "exportbackend-to-services-form-api-deployment" {
    content  = <<EOF
data "terraform_remote_state" "zones" {
   backend = "s3"
   config = {
        key = "vpcs/zone/zone.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../services/form/api/api-deployment/backend-exported-from-vpcs-zone.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
