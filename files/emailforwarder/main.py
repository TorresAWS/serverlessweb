import json

# Copyright 2010-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# This file is licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License. A copy of the
# License is located at
#
# http://aws.amazon.com/apache2.0/
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
# Adapted by DTR: made service-independent (it can be triggered by SES, SNS or SQS)

import os
import boto3
import email
import re
from botocore.exceptions import ClientError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from email import message_from_string
from jsonconv import *
import json
from email.policy import default
import ast




MailS3Bucket = 'name-of-the-bucket'
MailS3Prefix = 'prefix of the send rule (folder where I am saving emails in s3)'
MailSender = 'Verified Email in SES emails'
MailRecipient = 'Verified Email in SES emails too (This is the email I want to send emails to)'
Region = 'my region'

region = os.environ['Region']






def get_message_from_s3(message_id):

    incoming_email_bucket = os.environ['MailS3Bucket']
    incoming_email_prefix = os.environ['MailS3Prefix']

    if incoming_email_prefix:
        object_path = (incoming_email_prefix + "/" + message_id)
    else:
        object_path = message_id

    object_http_path = (f"http://s3.console.aws.amazon.com/s3/object/{incoming_email_bucket}/{object_path}?region={region}")

    # Create a new S3 client.
    client_s3 = boto3.client("s3")

    # Get the email object from the S3 bucket.
    object_s3 = client_s3.get_object(Bucket=incoming_email_bucket, Key=object_path)
    # Read the content of the message.
    file = object_s3['Body'].read()

    file_dict = {
        "file": file,
        "path": object_http_path
    }

    return file_dict

def create_message(file_dict):

    sender = os.environ['MailSender']
    recipient = os.environ['MailRecipient']

    separator = ";"

    # Parse the email body.
    mailobject = email.message_from_string(file_dict['file'].decode('utf-8'), policy=default)

    # Create a new subject line.
    subject_original = mailobject['Subject']
    subject = "FW: " + subject_original

    # The body text of the email.
    body_text = ("The attached message was received from "
              + separator.join(mailobject.get_all('From'))
              + ". This message is archived at " + file_dict['path'])

    # The file name to use for the attached message. Uses regex to remove all
    # non-alphanumeric characters, and appends a file extension.
    filename = re.sub('[^0-9a-zA-Z]+', '_', subject_original) + ".eml"

    # Create a MIME container.
    msg = MIMEMultipart()

    # Add subject, from and to lines.
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = recipient

    # Create a new MIME object.
    att = MIMEApplication(file_dict["file"], filename)
    att.add_header("Content-Disposition", 'attachment', filename=filename)

    # Attach the file object to the message.
    msg.attach(att)

    # creates an HTML table in the body of the email with email info 
    has_attachment=False
    if mailobject.is_multipart():
        has_attachment = True
        body = mailobject.get_body(('plain',))
        if body:
           body = body.get_content()
    else:
       body = mailobject.get_payload()
    email_dict = {
        "From": mailobject['From'],
        "To": mailobject['To'],
        "Subject": mailobject['Subject'],
        "Email": body,
        "Has Attachment": has_attachment
    }
    json_str = json.dumps(email_dict, indent=4) 
    emailaddress =  json.loads(json_str)
    body_text ="<html><head></head><body><h1>New Email</h1>"+ str(json2html.convert(json = emailaddress)) + "</body></html>"
    text_part = MIMEText(body_text, _subtype="html")
    msg.attach(text_part)

    message = {
        "Source": sender,
        "Destinations": recipient,
        "Data": msg.as_string()
    }

    return message

def send_email(message):
    aws_region = os.environ['Region']

# Create a new SES client.
    client_ses = boto3.client('ses', region)

    # Send the email.
    try:
        #Provide the contents of the email.
        response = client_ses.send_raw_email(
            Source=message['Source'],
            Destinations=[
                message['Destinations']
            ],
            RawMessage={
                'Data':message['Data']
            }
        )

    # Display an error if something goes wrong.
    except ClientError as e:
        output = e.response['Error']['Message']
    else:
        output = "Email sent! Message ID: " + response['MessageId']

    return output

def dentify_service(event,service):
# identifies the service as ses or sns
    match service:
        case 'aws:ses':
            return event['Records'][0]['ses']['mail']['messageId'] 
        case 'aws:sns':
            return json.loads(event['Records'][0]['Sns']['Message'])['mail']['messageId'] 
        case 'aws:sqs':
            return  json.loads(json.loads(event['Records'][0]['body'])['Message'])['mail']['messageId'] 
#        case _:
#            return ""



def lambda_handler(event, context):
    # Get the unique ID of the message. This corresponds to the name of the file
    # in S3.
    # event['Records'][0] has a different format based on what service (SES, SNS, SQS) triggers lambda
    # find the service (SES, SQS, SNS) that triggers lambda
    fullevent = event['Records'][0]
    fullevent =  {k.lower(): v for k, v in fullevent.items()}
    service = fullevent['eventsource']   
    # fins the id that is the S3 name inside the bucket
    message_id = dentify_service(event, service) 
    print(f"Received message ID {message_id}")
    # Retrieve the file from the S3 bucket.
    file_dict = get_message_from_s3(message_id)
    # Create the message.
    message = create_message(file_dict)
    # Send the email and print the result.
    result = send_email(message)
    print(result)

