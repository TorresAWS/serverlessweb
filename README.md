---
## Table of contents
1. [Introduction: serverless culture](#introduction)
2. [Goal](#goal)
3. [Startup the example](#Startup)
4. [Storage](#Storage)
5. [Simple Email Service](#SES)
6. [Roles](#Roles)
7. [Email forwarding service](#Email)
8. [Decoupling the email forwarding service](#Decoupling)
9. [Form submission](#Form)
10. [API deployment](#API)
11. [CloudFront deployment](#CloudFront)
12. [Conclusion](#conclusion)

## Introduction: serverless culture <a name="introduction"></a>
The serverless deployment of JS-based web applications is extremely <mark>affordable</mark>. Hosting a simple, serverless website in AWS costs only an average of $1 a month. This is in contrast to $20, the average cost of hosting services. The cost reduction offered by serverless hosting is unbeatable. 
When deploying serverless apps, we focus on writing and deploying code without managing the underlying server infrastructure. Cloud provider handles provisioning, scaling, and maintenance. On one hand, AWS, with its neverending list of services, is a perfect cloud provider for serverless deployment. On the other hand, infrastructure such as code (IaC) tools such as Terraform help build, change, and version infrastructure on the cloud. Unfortunately, avoiding web hosting services (think of GoDaddy) comes with a price in terms of complexity.
Serverless deployment does not naturally come with all benefits such as email services (sending and receiving) or even an email address matching your domain. Moreover, the use of forms, which are normally handled with technologies such as PHP, Python, or Node.js, does not easily translate to serverless. Fortunately, AWS has numerous services (Cloudfront, SES, Lambda) that can help us overcome all these difficulties.

## Goal <a name="goal"></a>
<div class="alert alert-block alert-info"> 
Here I will show how to deploy a simple web application containing a serverless form and how to build an email services matching your domain.
</div>

## Startup the example<a name="Startup"></a>
First, I will clone the repo, update the cloud profile data, start Terraform's backend. The steps are:

 ```
git clone https://github.com/TorresAWS/serverless-web-and-email
cd global/providers/
vi cloud.tf     	   # make sure you update your AWS profile info
```

On one hand, I focus here on AWS as a cloud provider, using Terraform to deploy all infrastructure in minutes. I assume your domain has been purchased through Route53 and as such it lives in AWS. If that is not the case, you'll need to manage the DNS records through your domain registrar and configure Route 53 as a DNS provider for that domain. Finally, I assume here you know some basics about how to use Terraform. On the other, this post is based on several of my other posts, as I use [multiaccount AWS environments](./aws-profiles/index.html) in Terraforn, I [syncronize DNSs](./aws-profiles/index.html) to speed up the approval of SSL/TLS certificates, and extensively [share Terraform variables ](./projectwide-variables/index.html) across all infrastructure.

The use of a proper folder structure is critical when using Terraform, as every piece of infrastructure lives in a separate folder. I used the following folder structure: global, vpcs, storage, services, and files. `Global` contains Terraform's backend, the variable's folder, and a bash-utilities folder. `vpcs` contains the certificates and zone's folders. The `storage` contains two buckets (website and email forwarding buckets). `Services` contain all services (cloudfromt, email forwarder, form). Finally,  the `files` folder contains all website and lambda files.


## Storage<a name="Storage"></a>
Now I will start two of the necessary storage services, the storage for the website service and the storage for the email-forwarding service. On one hand, the website storage was described [elsewhere](./aws-profiles/index.html). On the other hand, in order to set up the SES forwarding service storage you need to create a bucket and a policy that allows SES to save (put) emails in the bucket. In particular, you need to give the PutObject permission for the SES service from your account, and only for S3 objects under the email/ prefix.
You create an access control list that makes the bucket private and change the owenership properties so that all objects uploaded to the bucket become property of the bucket owner. Then you create a policy that allows SES to save objects in the bucket.



I will first create a bucket with a policy that allows SES to write in the bucket:

<h5 a><strong><code>vi storage/storage-emailforwarder/bucket.tf</code></strong></h5>

```
resource "aws_s3_bucket" "email" {
  provider    =  aws.Infrastructure
  bucket      = "${data.terraform_remote_state.variables.outputs.ses-bucket-name}"
  force_destroy =local.aws_s3_bucket_force_destroy
  timeouts {
    create = local.aws_s3_bucket_timeouts
  }
}
```

<h5 a><strong><code>vi storage/storage-emailforwarder/bucket_policy.tf</code></strong></h5>

```
resource "aws_s3_bucket_policy" "email" {
  provider    =  aws.Infrastructure
  bucket = aws_s3_bucket.email.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSESPuts",
      "Effect": "Allow",
      "Principal": {
        "Service": "ses.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.email.arn}/email/*",
      "Condition": {
        "StringEquals": {
        "aws:Referer": "${data.terraform_remote_state.variables.outputs.account_id}"
        }
      }
    }
  ]
}
EOF
}
```
  
The access control list was defined so that the bucket is private and the bucket ownership control so that the objects placed in the bucket by SES change ownership to the owner
  
<h5 a><strong><code>vi storage/storage-emailforwarder/bucket_acl.tf</code></strong></h5>

```
resource "aws_s3_bucket_acl" "example" {
  provider    =  aws.Infrastructure
  depends_on  = [aws_s3_bucket_ownership_controls.example]
  bucket      = aws_s3_bucket.email.id
  acl         = local.aws_s3_bucket_acl_acl
}
``` 
 
h5 a><strong><code>vi storage/storage-emailforwarder/bucket_ownership_controls.tf</code></strong></h5>

```
resource "aws_s3_bucket_ownership_controls" "example" {
  provider    =  aws.Infrastructure
  bucket = aws_s3_bucket.email.id
  rule {
    object_ownership = local.aws_s3_bucket_ownership_controls_rule_object_ownership
  }
}
``` 
  
## Simple Email Service<a name="SES"></a>

 In oder to startup the SES email service we need to create an identify: an email address that will receive all email communication. After you create this identity you will receive an email with a link in oder to validate the address.

h5 a><strong><code>vi services/ses/ses-email-identity.tf</code></strong></h5>

```
resource "aws_ses_email_identity" "semplates_email_identity" {
 provider    =  aws.Infrastructure
 email = "${data.terraform_remote_state.variables.outputs.ses-email}"
}
``` 
## Roles<a name="Roles"></a>

In order to build this infrastructure we need two roles. In AWS a role is an identity with permisions that can be assumed by an entity. As a note, these roles would be only accessible to Lambda.
One role (email forwarder role) allows SES to send emails saved in a S3 bucket (SES accessing the S3 service) and another role (form role) that allows Lambda to send SES emails (Lambda accessing the SES service). For each role, we need to create the role with a policy that specifies the tasks the role can acomplish. For the email-forwarder role, we have

<h5 a><strong><code>vi global/roles/lambda-emailforwarder/iam-role.tf</code></strong></h5>

```
resource "aws_iam_role" "lambda-email-forwarder" {
  provider    =  aws.Infrastructure
  name   =  "${data.terraform_remote_state.variables.outputs.lambda_role_name}"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": "AllowLambdaAssumeRole"
   }
 ]
}
EOF
}
``` 
<h5 a><strong><code>vi global/roles/lambda-emailforwarder/iam-policy.tf</code></strong></h5>

```
resource "aws_iam_policy" "Python-lambda-email-forwarder" {
 provider     =  aws.Infrastructure
 name         =  "${data.terraform_remote_state.variables.outputs.lambda_policy_role_name}"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy       = data.aws_iam_policy_document.lambda-email-forwarder.json
}
```

<h5 a><strong><code>vi global/roles/lambda-emailforwarder/iam-policy-document.tf</code></strong></h5>

```
data "aws_iam_policy_document" "lambda-email-forwarder" {
  provider    =  aws.Infrastructure
  statement {
    sid = "AllowLambdaToSendEmails"
    effect = "Allow"
    actions = [
        "s3:GetObject",
        "ses:SendRawEmail"
    ]
    resources = [
        "arn:aws:s3:::${data.terraform_remote_state.storage-ses-email.outputs.aws_s3_bucket_email_bucket}/*", "arn:aws:ses:${data.terraform_remote_state.variables.outputs.region}:${data.terraform_remote_state.variables.outputs.account_id}:identity/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
```
<h5 a><strong><code>vi global/roles/lambda-emailforwarder/iam-role-policy-attachment.tf</code></strong></h5>

```
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 provider    =  aws.Infrastructure
 role        = aws_iam_role.lambda-email-forwarder.name
 policy_arn  = aws_iam_policy.Python-lambda-email-forwarder.arn
}
```

For the form-sender role:

<h5 a><strong><code>vi global/roles/lambda-form/iam-role.tf</code></strong></h5>

```
resource "aws_iam_role" "lambda_role" {
  provider    =  aws.Infrastructure
  name   = "${data.terraform_remote_state.variables.outputs.lambda_send_email_from_api_role_name}"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": "AllowLambdaAssumeRole"
   }
 ]
}
EOF
} 
```

<h5 a><strong><code>vi global/roles/lambda-form/iam-policy.tf</code></strong></h5>

```
resource "aws_iam_policy" "iam_policy_for_lambda" {
 provider    =  aws.Infrastructure
 name         = "${data.terraform_remote_state.variables.outputs.lambda_send_email_from_api_role_policy_name}"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy      = data.aws_iam_policy_document.ses_send_templated_email_policy.json
} 
```
<h5 a><strong><code>vi global/roles/lambda-form/iam-policy-document.tf</code></strong></h5>

```
data "aws_iam_policy_document" "ses_send_templated_email_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = [
         "${data.terraform_remote_state.ses.outputs.aws-ses-email-identity-semplates-email-identity-arn}","arn:aws:ses:${data.terraform_remote_state.variables.outputs.region}:${data.terraform_remote_state.variables.outputs.account_id}:identity/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
} 
```


<h5 a><strong><code>vi global/roles/lambda-form/iam-role-policy-attachment.tf</code></strong></h5>

```
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 provider    =  aws.Infrastructure
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
} 
```

A final role was created in order to use the SMTP server from an email application such as Thunderbird. This allows you to send emails that can be received having our domian in the sender email. However, this will only work when sending emails to a verifies email address unless you get out of the SES sandbox mode. Other tools such as Twilio Sendgrid offer more flexibility for this matter. Anyway, I decided to post here the files for educational purposes

<h5 a><strong><code>vi global/roles/smtp/aws-iam-user.tf</code></strong></h5>

```
resource "aws_iam_user" "smtp_user" {
  name = "smtp_user"
  provider    =  aws.Infrastructure
}
``` 
 
<h5 a><strong><code>vi global/roles/smtp/aws-iam-policy.tf </code></strong></h5>

```
resource "aws_iam_policy" "ses_sender" {
 provider    =  aws.Infrastructure
  name        = "ses_sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}
```
 
<h5 a><strong><code>vi global/roles/smtp/aws-iam-policy-document.tf </code></strong></h5>

```
data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}
``` 

<h5 a><strong><code>vi global/roles/smtp/aws-iam-user-policy-attachment.tf </code></strong></h5>

```
resource "aws_iam_user_policy_attachment" "test-attach" {
 provider    =  aws.Infrastructure
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}
``` 

<h5 a><strong><code>vi global/roles/smtp/aws-iam-access-key.tf </code></strong></h5>

```
resource "aws_iam_access_key" "smtp_user" {
 user = aws_iam_user.smtp_user.name
 provider    =  aws.Infrastructure
}
``` 
SES smtp credentials are just iam credentials converted to smtp credentials. As such I just need to create  an IAM user with permits to send raw emails using SES. In order to print the password you need to add the 'sensitive' tag to the output variable.
  

## Email forwarding service<a name="Email"></a>
In order to forward emails received to your domain you would need to crease numerous Route 53 domain records (dkim, dmarc, mx, spf) as well as configure SES in order to receive emails and save then in storage and trigger a lamba funcion to send them to your email. Let me break down all these steps starting by the domain records. In short, we need two different infrastructure pieces: a SES depployment and a Lambda deployment.

Let me address the SES deployment. DKIM is a standard that allows senders to sign their email messages with a cryptographic key. An email message that is sent using DKIM includes a DKIM-Signature header field that contains a cryptographically signed representation of the message. An email provider that receives the message can use a public key, published as a DNS record, to decode the signature. Email providers use this information to determine whether a message is authentic. In order to create a Dkim records you have to use the following Terraform file

<h5 a><strong><code>vi global/services/emailforwarder/route53-dkim-record.tf </code></strong></h5>

```
resource "aws_route53_record" "amazonses_dkim_record" {
  provider    =  aws.Domain
  count   = 3
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"
  name    = "${aws_ses_domain_dkim.dkim_identity.dkim_tokens[count.index]}._domainkey.${aws_ses_domain_identity.domain_identity.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_ses_domain_dkim.dkim_identity.dkim_tokens[count.index]}.dkim.amazonses.com"]
}
``` 
The DMARC record contains instructions for email providers on how to handle unauthenticated mail. You can use the record to specify: which mechanism (DKIM, SPF or both) to employ, how the receiver should deal with failures, or where to send reports to. You must not have multiple DMARC records for a single domain. Below is the code to set up this records

<h5 a><strong><code>vi global/services/emailforwarder/route53-dmarc-record.tf </code></strong></h5>

```
resource "aws_route53_record" "dmarc_txt" {
  provider    =  aws.Domain
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"
  name    = "_dmarc.${data.terraform_remote_state.variables.outputs.domain}"
  type    = "TXT"
  ttl     = "300"
  records = [
   "v=DMARC1; p=none;"
  ]
}
 ``` 

An MX record (Mail Exchange record) is a type of DNS record that specifies which mail servers are responsible for accepting incoming email messages for a particular domain. Below is the code to set up this records

<h5 a><strong><code>vi global/services/emailforwarder/route53-mx-record.tf </code></strong></h5>

```
 resource "aws_route53_record" "email" {
  provider    =  aws.Domain
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"
  name    = "${data.terraform_remote_state.variables.outputs.domain}"
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${data.terraform_remote_state.variables.outputs.region}.amazonaws.com"]
}
 ``` 

An SPF record indicates which domains are authorized for sending messages. Email providers use this information to determine whether a message comes from a verified source. Below is the code to set up this records, a receip rule set, and a domain mail from.

<h5 a><strong><code>vi global/services/emailforwarder/route53-spf-record.tf </code></strong></h5>

```
resource "aws_route53_record" "root_txt" {
  provider    =  aws.Domain
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"
  name    = "${aws_ses_domain_mail_from.example.mail_from_domain}"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=spf1 include:amazonses.com ~all"
  ]
} 
 ``` 

Now in order to set up the SES service for email forwarding we will have to create a domain identity, verify the identity, set up the dkim domain, create an active recipient set list, a configuration set, 
 
<h5 a><strong><code>vi global/services/emailforwarder/ses-domain-identity.tf </code></strong></h5>

```
resource "aws_ses_domain_identity" "domain_identity" {
  provider    =  aws.Infrastructure
  domain = "${data.terraform_remote_state.variables.outputs.domain}"
} 
 ``` 

<h5 a><strong><code>vi global/services/emailforwarder/ses-domain-identity-verification.tf </code></strong></h5>

```
resource "aws_ses_domain_identity_verification" "domain_identity_verification" {
  provider    =  aws.Infrastructure
  domain = aws_ses_domain_identity.domain_identity.id
  depends_on = [aws_route53_record.amazonses_dkim_record]
}
 
 ```  
 
 <h5 a><strong><code>vi global/services/emailforwarder/ses-domain-dkim.tf </code></strong></h5>

```
resource "aws_ses_domain_dkim" "dkim_identity" {
  provider    =  aws.Infrastructure
  domain = aws_ses_domain_identity.domain_identity.domain
} 
 ``` 
 
 <h5 a><strong><code>vi global/services/emailforwarder/ses-active-receipt-rule-set.tf </code></strong></h5>

```
resource "aws_ses_active_receipt_rule_set" "primary" {
  provider    =  aws.Infrastructure
  rule_set_name = aws_ses_receipt_rule_set.primary.rule_set_name
} 
 ``` 
 
 
 <h5 a><strong><code>vi global/services/emailforwarder/ses-receipt-rule-set.tf </code></strong></h5>

```
resource "aws_ses_receipt_rule_set" "primary" {
  provider    =  aws.Infrastructure
  rule_set_name = "primary"
} 
 ``` 
 
 <h5 a><strong><code>vi global/services/emailforwarder/ses-domain-mail-from.tf </code></strong></h5>

```
resource "aws_ses_domain_mail_from" "example" {
  provider    =  aws.Infrastructure
  domain           =  "${aws_ses_domain_identity.domain_identity.domain}"
  mail_from_domain = "mail.${aws_ses_domain_identity.domain_identity.domain}"
} 
 ``` 
Let me address the Lambda deployment to forward emails. We would need to define the funcion with its permisions (lambda-function.tf and lambda-permision.tf), a layer (lambda-layer.tf ) and an alias (lambda-alias.tf). I will also create a cloudwatch log group  (cloudwatch-log-group.tf) and zip the python file (data-zip.tf) containing the code automatically. Finally I will create a SES receip rule (ses_receipt_rule.tf)


<h5 a><strong><code>vi global/services/emailforwarder/lambda-emailforwarder/lambda-function.tf </code></strong></h5>

```
resource "aws_lambda_function" "email-forwarder" {
 provider    =  aws.Infrastructure
 filename      = "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder/lambda.zip"
 function_name =  "python-lambda-email-forwarder"
 role          = "${data.terraform_remote_state.lambda-send-email-from-s3-role.outputs.arn}"
 handler       = "main.lambda_handler"
 timeout       = 30
 runtime       = "python3.12"
 source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
 environment {
    variables = {
      MailS3Bucket  = "${data.terraform_remote_state.storage-ses-email.outputs.aws_s3_bucket_email_bucket}"
      MailS3Prefix  = "email"
      MailSender    = "info@${data.terraform_remote_state.variables.outputs.domain}"
      MailRecipient =  "${data.terraform_remote_state.variables.outputs.ses-email}"
      Region        = "${data.terraform_remote_state.variables.outputs.region}"
    }
  }
} 
 ```

<h5 a><strong><code>vi global/services/emailforwarder/lambda-emailforwarder/lambda-permision.tf </code></strong></h5>

```
resource "aws_lambda_permission" "email" {
 provider    =  aws.Infrastructure
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.email-forwarder.function_name
  principal      = "ses.amazonaws.com"
  source_account = "${data.terraform_remote_state.variables.outputs.account_id}"
} 
 ```
 
 <h5 a><strong><code>vi global/services/emailforwarder/lambda-emailforwarder/lambda-layer.tf </code></strong></h5>

```
resource "aws_lambda_layer_version" "email-forwarder" {
 provider    =  aws.Infrastructure
 filename   =  "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder/lambda.zip"
 layer_name =  "my_python_layer"
 compatible_runtimes = ["python3.11"]
} 
 ```
 

  <h5 a><strong><code>vi global/services/emailforwarder/lambda-emailforwarder/lambda-alias.tf </code></strong></h5>

```
resource "aws_lambda_alias" "email-forwarder" {
  provider    =  aws.Infrastructure
 name             = "dev"
 function_name    = aws_lambda_function.email-forwarder.function_name
 function_version = aws_lambda_function.email-forwarder.version
} 
```
 
I will also create a cloudwatch log group  (cloudwatch-log-group.tf) and zip the python file (data-zip.tf) containing the code automatically. 
 
<h5 a><strong><code>vi global/services/emailforwarder/lambda-emailforwarder/data-zip.tf </code></strong></h5>

```
data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder"
output_path = "${data.terraform_remote_state.variables.outputs.path_to_lambda}/emailforwarder/lambda.zip"
}
``` 

<h5 a><strong><code>vi global/services/emailforwarder/lambda-emailforwarder/cloudwatch-log-group.tf </code></strong></h5>

```
resource "aws_cloudwatch_log_group" "lambda-email-forwarder" {
 provider          =  aws.Infrastructure
 name              = "/aws/services/emailforwarder/lambda-emailforwarder"
 retention_in_days = 14
}
```  
 
## Decoupling the email forwarding service<a name="Decoupling"></a>

The email forwarding service needs to be decoupled so that when SES is triggered, this triggers lambda indirectly, hence limiting concurrent executions. In order to accomplish this, I will use SNS coupled with SQS. 
I will first create an SNS topic 

<h5 a><strong><code>vi global/services/emailforwarder/sns-emailforwarder/sns-topic.tf </code></strong></h5>
```
resource "aws_sns_topic" "emailforwarder" {
    provider    =  aws.Infrastructure
    name = "emailforwarder"
}
```

with a policy that limits its actions.

<h5 a><strong><code>vi global/services/emailforwarder/sns-emailforwarder/sns-topic-policy.tf </code></strong></h5>

```
resource "aws_sns_topic_policy" "default" {
  provider    =  aws.Infrastructure
  arn = aws_sns_topic.emailforwarder.arn
  policy = data.aws_iam_policy_document.emailforwarder.json
  depends_on = [aws_sns_topic.emailforwarder]
}
```
 <h5 a><strong><code>vi global/services/emailforwarder/sns-emailforwarder/sns-topic-policy-data.tf </code></strong></h5>

```
data "aws_iam_policy_document" "emailforwarder" {
  policy_id = "__default_policy_ID"
  provider    =  aws.Infrastructure
 statement {
    actions = [
      "SNS:Publish",
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
       "arn:aws:sns:us-east-1:211125559094:emailforwarder"
    ]
  }
```

An SES rule will make sure that once SES receives an email it saves it in SES and triggers SNS

<h5 a><strong><code>vi global/services/emailforwarder/sns-emailforwarder/ses-receipt-rule.tf</code></strong></h5>

```
resource "aws_ses_receipt_rule" "email" {
 provider    =  aws.Infrastructure
  name          = "email-sns-forwarder"
  rule_set_name = "${data.terraform_remote_state.ses-email.outputs.aws_ses_receipt_rule_set_primary_rule_set_name}"
  recipients    = [for username in data.terraform_remote_state.variables.outputs.email_usernames : "${username}@${data.terraform_remote_state.variables.outputs.domain}"]
  enabled       = true
  scan_enabled  = false

  s3_action {
    position          = 1
    bucket_name       = "${data.terraform_remote_state.storage-ses-email.outputs.aws_s3_bucket_email_bucket}"
    object_key_prefix = "email/"
  }
  sns_action {
    position  = 2
    topic_arn = aws_sns_topic.emailforwarder.arn
  }
  depends_on = [aws_sns_topic.emailforwarder]
}
```

I will also create an SQS queue.

<h5 a><strong><code>vi global/services/emailforwarder/sqs-emailforwarder/sqs-queue.tf </code></strong></h5>

```
resource "aws_sqs_queue" "emailforwarder" {
  name = "emailforwarder"
  redrive_policy  = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.emailforwarder-dl.arn}\",\"maxReceiveCount\":5}"
  provider    =  aws.Infrastructure
  visibility_timeout_seconds = 300
  message_retention_seconds  = 345600
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
}
```
With a policy triggers SQS when SNS sends a message

<h5 a><strong><code>vi global/services/emailforwarder/sqs-emailforwarder/sqs-queue-policy.tf</code></strong></h5>

```
resource "aws_sqs_queue_policy" "emailforwarder" {
    provider    =  aws.Infrastructure
    queue_url = "${aws_sqs_queue.emailforwarder.id}"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.emailforwarder.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${data.terraform_remote_state.sns-emailforwarder.outputs.aws-sns-topic-emailforwarder-arn}"
        }
      }
    }
  ]
}
POLICY
}
```
A death letter policy will collect unprocessed messages

<h5 a><strong><code>vi global/services/emailforwarder/sqs-emailforwarder/sqs-queue-deathletter.tf</code></strong></h5>

```
resource "aws_sqs_queue" "emailforwarder-dl" {
    name = "sqs-queue-dl"
provider    =  aws.Infrastructure
}
```

So that SQS can execute Lambda I will create an event source mapping

<h5 a><strong><code>vi global/services/emailforwarder/sns-emailforwarder/lambda-event-source-mapping.tf </code></strong></h5>

```
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  provider         = aws.Infrastructure
  event_source_arn = aws_sqs_queue.emailforwarder.arn
  enabled          = true
  function_name    =  "${data.terraform_remote_state.lambda-emailforwarder.outputs.aws_lambda_function-email-forwarder-arn}"
  batch_size       = 1
}
```

and give SQS permissions to execute lambda

<h5 a><strong><code>vi global/services/emailforwarder/sns-emailforwarder/lambda-permision.tf </code></strong></h5>

```
resource "aws_lambda_permission" "with_sqs" {
  statement_id  = "AllowExecutionFromSQS"
  provider      =  aws.Infrastructure
  action        = "lambda:InvokeFunction"
  function_name = "${data.terraform_remote_state.lambda-emailforwarder.outputs.aws_lambda_function-email-forwarder-function_name}"
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.emailforwarder.arn
}
```



 
## Form submission<a name="Form"></a>
 
Now I will describe how to create a Lambda Function that is triggered by an API so that an email is send whenever a form is submited in the website. We will have to deploy a regular Lambda function and hence we will need a function (lambda-function.tf), a layer (lambda-layer-version.tf) and an alias (lambda-alias.tf).

<h5 a><strong><code>vi global/services/form/lambda-form/lambda-function.tf </code></strong></h5>

```
resource "aws_lambda_function" "PythonSesEmailSender" {
 provider    =  aws.Infrastructure
 filename      = "${path.module}/../../../files/form/lambda.zip"
 function_name = "python-lambda-general-json"
 role          = "${data.terraform_remote_state.lambda-send-email-from-api-role.outputs.arn}"
 handler       = "main.lambda_handler"
 timeout       = 60
  runtime       = "python3.11"
  environment {
    variables = {
      SES_REGION = "${data.terraform_remote_state.variables.outputs.region}"
      MailSender    = "${data.terraform_remote_state.variables.outputs.ses-email}"
      MailRecipient = "info@${data.terraform_remote_state.variables.outputs.domain}"
    }
  }
}
```  

<h5 a><strong><code>vi global/services/form/lambda-form/lambda-layer-version.tf </code></strong></h5>

```
resource "aws_lambda_layer_version" "PythonSesEmailSender" {
 provider    =  aws.Infrastructure
 filename   = "${path.module}/../../../files/form/lambda.zip"
 layer_name = "my_python_layer"
 compatible_runtimes = ["python3.11"]
}
``` 

<h5 a><strong><code>vi global/services/form/lambda-form/lambda-alias.tf </code></strong></h5>

```
resource "aws_lambda_alias" "PythonSesEmailSender" {
  provider    =  aws.Infrastructure
 name             = "dev"
 function_name    = aws_lambda_function.PythonSesEmailSender.function_name
 function_version = aws_lambda_function.PythonSesEmailSender.version
}
``` 


I will also to zip the layer data (data-zip.tf) and to start the log collection with cloudWatch (cloudwatch-log-group.tf):

<h5 a><strong><code>vi global/services/form/lambda-form/data-zip.tf </code></strong></h5>

```
data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/../../../files/form/"
output_path = "${path.module}/../../../files/form/lambda.zip"

}
``` 
<h5 a><strong><code>vi global/services/form/lambda-form/cloudwatch-log-group.tf </code></strong></h5>

```
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  provider    =  aws.Infrastructure
 name              = "/aws/form/lambda-form"
 retention_in_days = 14
}
``` 
 
 
 
## API deployment<a name="API"></a>
 An API (Application Programming Interface) is a set of methods and specifications that act as a bridge, enabling applications to interact without needing to know the internal workings of the other application. Why do we need an API in our example? Our form will gather data and our lambda function will send this data in the form of an e-mail. However, we still need a bridge between the web form and the function. Our API will precisely do that. By bridging our JS code with our Lambda interface, we will use APIGateway, an AWS service that allows us to quickly create APIs. 
In order to create an API gateway we will first select the type of API we want between HTTP(minimal), REST (unidirectional), and WebSocket (bidirectional) APIs. We will select REST as the form submission would be unidirectional. We will first create the gateway and its resources, and we would also need to give permisions to the API to access the Lambda service:

<a><strong><code>vi services/form/api/api-gateway/api-gateway.tf</code></strong></h5>

```
resource "aws_api_gateway_rest_api" "PythonSesEmailSender" {
 provider    =  aws.Infrastructure
 name        = "my_api_gateway"
 description = "API Gateway for form"
}
```

<a><strong><code>vi services/form/api/api-gateway/api-resources.tf</code></strong></h5>

```
resource "aws_api_gateway_resource" "proxy" {
  provider    =  aws.Infrastructure
  rest_api_id = "${aws_api_gateway_rest_api.PythonSesEmailSender.id}"
  parent_id   = "${aws_api_gateway_rest_api.PythonSesEmailSender.root_resource_id}"
  path_part   = "${data.terraform_remote_state.variables.outputs.api_path_name}"
}
```

<a><strong><code>vi services/form/api/api-gateway/lambda-permision.tf</code></strong></h5>

```
resource "aws_lambda_permission" "PythonSesEmailSender" {
 provider = aws.Infrastructure
 statement_id = "AllowAPIGatewayInvoke"
action ="lambda:InvokeFunction"
 function_name = "${data.terraform_remote_state.lambda-general-json.outputs.aws-lambda-function-PythonSesEmailSender-function-name}"
 principal = "apigateway.amazonaws.com"
 source_arn = "${aws_api_gateway_rest_api.PythonSesEmailSender.execution_arn}/*/*"
}
```



In order to make the API work we would need: a method request (with a PUT method), a method response, an integration request (to integrate the method to Lambda), and an integration response. These tools are needed to process the incoming requests and the outgoing responses.

<a><strong><code>vi services/form/api/api-form/api-method.tf</code></strong></h5>

```
resource "aws_api_gateway_method" "proxy" {
  provider    =  aws.Infrastructure
  rest_api_id   = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id   = "${data.terraform_remote_state.api.outputs.resource_id}"
  http_method   = "PUT"
  authorization = "NONE"
}
```

<a><strong><code>vi services/form/api/api-form/api-method-response.tf</code></strong></h5>

```
resource "aws_api_gateway_method_response" "mockresponse" {
  provider    =  aws.Infrastructure
  rest_api_id =  "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  status_code = "200"
  depends_on = [aws_api_gateway_method.proxy]
}
```


<a><strong><code>vi services/form/api/api-form/api-integration.tf</code></strong></h5>

```
resource "aws_api_gateway_integration" "integrate" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${data.terraform_remote_state.lambda-general-json.outputs.aws-lambda-function-PythonSesEmailSender-invoke-arn}"
}
```

<a><strong><code>vi services/form/api/api-form/api-integration-response.tf</code></strong></h5>

```
resource "aws_api_gateway_integration_response" "mockresponse" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  status_code = "200"
  depends_on = [aws_api_gateway_integration.integrate ]
}
```

We would need to enable CORS (Cross-Origin Resource Sharing) so that our JS code is able to access the API hosted in another domain. In order to do this, we would develop a new method and as such we would need the four elements described above:


 <a><strong><code>vi services/form/api/api-cors/api-integration-cors.tf</code></strong></h5>

```
resource "aws_api_gateway_integration" "cors_integration" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id = "${data.terraform_remote_state.api.outputs.resource_id}"
  http_method = aws_api_gateway_method.cors_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
```
<a><strong><code>vi services/form/api/api-cors/api-integration-response-cors.tf</code></strong></h5>

```
resource "aws_api_gateway_integration_response" "cors_integration_response" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id = "${data.terraform_remote_state.api.outputs.resource_id}"
  http_method = aws_api_gateway_method.cors_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,PUT,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
   depends_on = [aws_api_gateway_integration.cors_integration]
}
```


<a><strong><code>vi services/form/api/api-cors/api-method-cors.tf</code></strong></h5>

```
resource "aws_api_gateway_method" "cors_options" {
  provider    =  aws.Infrastructure
  rest_api_id   = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id   = "${data.terraform_remote_state.api.outputs.resource_id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}
```

<a><strong><code>vi services/form/api/api-cors/api-method-response-cors.tf</code></strong></h5>

```
resource "aws_api_gateway_method_response" "cors_method_response" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  resource_id = "${data.terraform_remote_state.api.outputs.resource_id}"
  http_method = aws_api_gateway_method.cors_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
```

Finally, we will deploy the API and give it a stage name (V1):

<a><strong><code>vi services/form/api/api-deployment/api-deployment.tf</code></strong></h5>

```
resource "aws_api_gateway_deployment" "example" {
  provider    =  aws.Infrastructure
  rest_api_id = "${data.terraform_remote_state.api.outputs.rest_api_id}"
}
```

<a><strong><code>vi services/form/api/api-deployment/api-stage.tf</code></strong></h5>

```
resource "aws_api_gateway_stage" "example" {
  provider    =  aws.Infrastructure
  stage_name    = "${data.terraform_remote_state.variables.outputs.stage_name}"
  rest_api_id   = "${data.terraform_remote_state.api.outputs.rest_api_id}"
  deployment_id = aws_api_gateway_deployment.example.id
}
```

We will also add an A DNS record into our domain zone, integrate the custom domain into the API and wait until the domain propagates:

<a><strong><code>vi services/form/api/api-deployment/api-domain.tf</code></strong></h5>

```
resource "aws_api_gateway_domain_name" "domain" {
  provider    =  aws.Infrastructure
  certificate_arn =  "${data.terraform_remote_state.certs.outputs.aws-acm-certificate-domain-arn}"
  domain_name     = "${data.terraform_remote_state.variables.outputs.api_domain}.${data.terraform_remote_state.variables.outputs.domain}"
}
```


<a><strong><code>vi services/form/api/api-deployment/api-domain-wait.tf</code></strong></h5>

```
resource "null_resource" "wait" {
 provisioner "local-exec" {
 command = "until curl --silent ${aws_api_gateway_domain_name.domain.domain_name} > /dev/null ;do sleep 1; done "
 }
 deppends_on = [aws_route53_record.domain]
 }
```

<a><strong><code>vi services/form/api/api-deployment/api-domain-A-record.tf</code></strong></h5>

```
resource "aws_route53_record" "domain" {
  name    = aws_api_gateway_domain_name.domain.domain_name
  type    = "A"
  zone_id = "${data.terraform_remote_state.zones.outputs.zone_id}"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.domain.cloudfront_zone_id
  }
}
```


At this point we can deploy the API by executing the bash script:


```
bash start.sh
```

  




