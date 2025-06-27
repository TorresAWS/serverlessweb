#data "terraform_remote_state" "variables" {
#   backend = "s3"
#   config = {
#        key = "global/variables/variables.tfstate"
#        region = "us-east-1"
#        profile  = "InfrastructureAIM"
#        bucket  =  "tfstate03062025" 
#   }
#}
