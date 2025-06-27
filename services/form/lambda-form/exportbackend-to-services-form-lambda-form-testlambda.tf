resource "local_file" "exportbackend-to-form-lamnda-testlambda" {
    content  = <<EOF
data "terraform_remote_state" "lambda-general-json" {
   backend = "s3"
   config = {
        key = "services/lambda-form/lambda-form.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "${data.terraform_remote_state.variables.outputs.backendname}"
   }
}
    EOF
    filename = "../../../services/form/lambda-form/testlambda/backend-exported-from-services-form-lambda-form.tf"
    depends_on = [data.terraform_remote_state.variables ]
}
