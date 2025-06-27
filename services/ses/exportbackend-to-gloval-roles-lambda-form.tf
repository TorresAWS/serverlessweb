resource "local_file" "exportbackend-to-gloval-roles-lambda-form" {
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
    filename = "../../global/roles/lambda-form/backend-exported-from-services-ses.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
