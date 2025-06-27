resource "local_file" "exportbackend-to-storage-storage-emailforwarder" {
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
    filename = "../../storage/storage-emailforwarder/backend-exported-from-global-variables.tf"
}
