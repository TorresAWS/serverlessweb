data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder"
output_path = "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder/lambda.zip"
}
