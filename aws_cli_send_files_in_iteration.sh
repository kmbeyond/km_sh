
#send all files at once
temp_role=$(aws sts assume-role --role-arn arn:aws:iam::111:role/customer_role --role-session-name km-session-001 --profile local_user_profile --duration-seconds 10800)
echo $temp_role

export AWS_ACCESS_KEY_ID=$(echo $temp_role | python2 -c "import sys, json; print json.load(sys.stdin)['Credentials']['AccessKeyId']")
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | python2 -c "import sys, json; print json.load(sys.stdin)['Credentials']['SecretAccessKey']")
export AWS_SESSION_TOKEN=$(echo $temp_role | python2 -c "import sys, json; print json.load(sys.stdin)['Credentials']['SessionToken']")

cd /path/files/
aws s3 cp . s3://kmbkt/input/ --recursive

#to send each file iteratively (Not recommended due to multiple API calls, but solution if needed)
#flow:
#send file
#if errored, retry for 3 times
#if failed 3 times, get new session credentials till it succeeds
#send file again, repeat same if errored

for file_to_send in $(ls *.pgp | awk '{print $1}'); do
 echo "----------------"
 echo "-> $file_to_send"
 aws s3 cp $file_to_send s3://kmbkt/input/
 result=$?
 if [ $result -eq 0 ]; then
  echo "  -> deleting...";
  rm $file_to_send
 else
  counter=1
  while [ $result -ne 0 ]; do
   echo "  -> FAILED. retry# $counter";
   aws s3 cp $file_to_send s3://kmbkt/input/
   if [ $? -eq 0 ]; then
     echo "  -> SUCCESS deleting...";
     rm $file_to_send
     result=0
   else
    if [ $counter -ge 3 ]; then
      result_cred=1
      while [ $result_cred -ne 0 ]; do
       sleep 10
       echo "  -> new session cred..";
       temp_role=$(aws sts assume-role --role-arn arn:aws:iam::111:role/customer_role --role-session-name km-session-001 --profile local_user_profile --duration-seconds 10800)
       result_cred=$?
      done
      export AWS_ACCESS_KEY_ID=$(echo $temp_role | python2 -c "import sys, json; print json.load(sys.stdin)['Credentials']['AccessKeyId']")
      export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | python2 -c "import sys, json; print json.load(sys.stdin)['Credentials']['SecretAccessKey']")
      export AWS_SESSION_TOKEN=$(echo $temp_role | python2 -c "import sys, json; print json.load(sys.stdin)['Credentials']['SessionToken']")
    fi
   fi
   counter=$((counter+1))
  done 
 fi
done

