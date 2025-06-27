#id=$1
#curl https://${id}.execute-api.us-east-1.amazonaws.com/V1/api -X PUT -H \"Content-Type:application/json\" -d '  {   "email": "dan@gmail.com"}'  
curl https://api.flat-cloud.com/api -X PUT -H \"Content-Type:application/json\" -d '  {   "api tested": "status=OK"}'  
