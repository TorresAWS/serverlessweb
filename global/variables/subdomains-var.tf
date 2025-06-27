variable "subdomains" {
# the domain will forwards all emails to this email address
# change this email
  default = ["www","api"] 
  type=list
}
