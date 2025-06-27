data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/../../../files/form/"
output_path = "${path.module}/../../../files/form/lambda.zip"

}
