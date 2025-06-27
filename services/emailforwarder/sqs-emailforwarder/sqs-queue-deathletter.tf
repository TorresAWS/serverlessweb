resource "aws_sqs_queue" "emailforwarder-dl" {
    name = "sqs-queue-dl"
provider    =  aws.Infrastructure
}
