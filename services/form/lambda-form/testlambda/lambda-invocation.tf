data  "aws_lambda_invocation" "example2" {
  provider    =  aws.Infrastructure
  function_name = "${data.terraform_remote_state.lambda-general-json.outputs.aws-lambda-function-PythonSesEmailSender-function-name}" 
  input = <<JSON
[  
  {
    "email": "dan@gmial.com",
    "type": "dog",
    "price": 249.99
  },
  {
    "id": 2,
    "type": "cat",
    "price": 124.99
  },
  {
    "id": 3,
    "type": "fish",
    "price": 0.99
  }
]
JSON
}


