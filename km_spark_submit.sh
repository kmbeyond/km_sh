#!/bin/sh
echo "------------ process: km_spark_submit.sh.sh --------------------"

kinit -kt /home/hrmn/.hrmn.keytab hrmn@AD001.ABC.COM

echo "Getting parameters script: /scripts/shellscripts/app_params.sh"
rm -f /tmp/app_params.sh
PRODhdfs dfs -get /scripts/shellscripts/app_params.sh /tmp/
RC="$?"
if [ $RC != 0 ]; then
  echo "*** ERROR in getting params shell script file: /scripts/shellscripts/data_comm/zip_assign_params.sh ***";
  email_status "${alert_email_addr}" "ERROR:CG-10-run: CSIG Oozie ${0} failed to get params script file" "ERROR:CG-10-run: CSIG Oozie shell script failed to get /scripts/shellscripts/data_comm/zip_assign_params.sh; Exit code: ${RC}"
  exit 99
fi;
chmod 775 /tmp/app_params.sh
. /tmp/app_params.sh
rm -f /tmp/app_params.sh

processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/zip_assign_${processDate}_$HOSTNAME.log

echo "--------------------------------------------------------------------------------" 2>&1 | tee -a  ${log_file}
echo "------------  process: km_spark_submit.sh --------------------" 2>&1 | tee -a  ${log_file}
echo "--------------------------------------------------------------------------------" 2>&1 | tee -a  ${log_file}
echo "---   INPUT ARGUMENTS ---" 2>&1 | tee -a  ${log_file}
echo "path_shellscripts_hdfs = ${path_shellscripts_hdfs}" 2>&1 | tee -a  ${log_file}
echo "path_sql_hdfs          = ${path_sql_hdfs}" 2>&1 | tee -a  ${log_file}
echo "hive_url               = ${hive_url}" 2>&1 | tee -a  ${log_file}


kinit -kt ${pr_keytab} ${principal}


spark2-submit --name "Spark Job By Staging from Oozie" \
      --class com.wp.da.ZipAssignmentByIntervalsWithStaging  \
      --master yarn --deploy-mode cluster  \
      --driver-class-path /etc/spark2/conf:/etc/hive/conf \
      --queue ${pool_name} \
      --num-executors 10 --executor-cores 5 --executor-memory 30G --driver-memory 40G \
      --conf spark.yarn.executor.memoryOverhead=6096 \
      --conf spark.ui.port=44444 \
      --conf spark.port.maxRetries=100 \
      --conf spark.yarn.principal=${principal} \
      --conf spark.yarn.keytab=${pr_keytab} \
     /tmp/${jar_file_w_path} ${db_hive} 250 15   #>>  ${log_file}

    jobStatus=$?
#--driver-memory 10g --num-executors 17 --executor-memory 12g --executor-cores
#      --conf 'spark.driver.extraJavaOptions=-XX:+UseCompressedOops -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps' \
#      --conf 'spark.executor.extraJavaOptions=-XX:+UseCompressedOops -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC' \

    echo "Job response: $jobStatus" 2>&1 | tee -a  ${log_file}
#rm -f /tmp/.n45156a.keytab
    rm -f /tmp/${jar_file_w_path}
    echo "******* Job Status/Response code: ${jobStatus} *******" 2>&1 | tee -a  ${log_file}
    case ${jobStatus} in
      "0")
        echo "******* JOB SUCCESS *******" 2>&1 | tee -a  ${log_file}
        ;;
      "101")
        hdfs dfs -put -f ${log_file} ${path_hdfs_app_root}/logs/
        exit 102
        ;;
      *)
        echo "******* ERROR:a: JOB FAILED: Unknown exception during Spark Job processing. ******" 2>&1 | tee -a ${log_file}
        email_status "${alert_email_addr}" "ERROR: has errors in Spark job: $jobStatus" "ERROR: errors in Spark job: $jobStatus"
        hdfs dfs -put -f ${log_file} ${path_hdfs_app_root}/logs/
        exit 999
        ;;
     esac

echo "---------------- COMPLETE -----------------" 2>&1 | tee -a  ${log_file}

hdfs dfs -put -f ${log_file} ${path_hdfs_app_root}/logs/
jobStatus=$?
if [ $jobStatus != 0 ]; then
  email_status "$alert_email_addr" "ERROR:aa: Error sending log file to HDFS" "ERROR:aa: Error while sending log file to HDFS."
  exit 110
fi


RC="$?"
if [ $RC == "0" ]; then
 echo "Script executed successfully."
 exit 0
else
 echo "Script failed"
 email_status "${alert_email_addr}" "ERROR:aa: CSIG Oozie shell script ${0} failed to execute script" "ERROR:aa: CSIG Oozie shell script failed to execute script: ${0}; Exit code: ${RC}"
 exit $RC
fi
