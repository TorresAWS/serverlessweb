import os
import boto3
import json
from botocore.exceptions import ClientError
from jsonconv import *
#import variables

#
# region=os.environ['SES_REGION']
# email=os.environ['MailSender']
def lambda_handler(event, context):
    CHARSET = "UTF-8"
    AWS_REGION = "us-east-1"
    BODY_TEXT = ("Amazon SES Test (Python)\r\n"
                 "This email was sent with Amazon SES using the "
                 "AWS SDK for Python (Boto)."
                )

    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>New Subscription</h1>
      <p>From...</p>
                """
    json_str = json.dumps(event) 
    emailaddress =  json.loads(json_str)
    BODY_HTML +=str(json2html.convert(json = emailaddress)) + "</body></html>"

    ses_client = boto3.client('ses', region_name=os.environ['SES_REGION'])
    try:
        response = ses_client.send_email(
#            Source= os.environ['MailSender'] ,
            Source= os.environ['MailRecipient']  ,
            Destination={
                'ToAddresses': [
                    os.environ['MailSender'],
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Data': 'New Subscription!',
                },
            }
        )
        return {
           'statusCode': 200 ,
           'body': json.dumps("Email Sent Successfully. MessageId is: " + response['MessageId'])
        }
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])

