resource "aws_sns_topic" "emailforwarder" {
    provider    =  aws.Infrastructure
    name = "emailforwarder"
}
