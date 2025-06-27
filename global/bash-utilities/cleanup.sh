#!/bin/bash
PATH_TO_INFRASTRUCTURE="/Users/daniel/GD/Soft/Website/serverless-web-and-email"
j=`paste orchestrationorder.txt`
jr=$(echo "$j" | tr ' ' '\n' | tac | xargs)
for i in $jr ; do 
cd ${PATH_TO_INFRASTRUCTURE}/$i ;
terraform destroy --auto-approve ; rm -rf .terraform* 
echo $i ;
done

