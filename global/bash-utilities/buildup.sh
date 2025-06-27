#!/bin/bash
PATH_TO_INFRASTRUCTURE="/Users/daniel/GD/Soft/Website/serverless-web-and-email"
j=`paste orchestrationorder.txt`
for i in $j ; do
cd ${PATH_TO_INFRASTRUCTURE}/$i ;
echo $i ;
bash ./start.sh
done

