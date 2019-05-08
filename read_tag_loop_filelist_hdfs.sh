#!/bin/sh

processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/km_${processDate}_01_read_tag_$HOSTNAME.log

#------ functions: START-----------------
function email_status
{
 to_address="$1"
 subject="$2"
 message="$3"
 mailx -s "${subject}" "${to_address}" <<EOF
$message
EOF
}

beeline -u "${hive_url}" -e "set mapreduce.job.queuename=${pool_name};" \
      "insert into table ${db_hive}.km_logs select current_timestamp(), 'km', '001', 'read_tag.sh', 0, 'Read tag files START.'" >> ${log_file}


#LOCAL-- if [ $(ls ${path_data_source}/*.tag | wc -l) == 0 ]; then
hdfs dfs -get ${path_data_source}/km_*.tag /tmp/
if [ $? != 0 ]; then
  echo "No tag file found: ${path_data_source}/km_*.tag" 2>&1 | tee -a ${log_file}
  email_status "$alert_email_addr" "WARN:01: Tag Source data (tag file) not found" "WARN:01: Tag Source data not found"
  hdfs dfs -put -f ${log_file} ${path_hdfs_app_root}/logs/
  exit 0
else

chmod 777 /tmp/km*.tag
#XfilesList=$(hdfs dfs -ls -t -h ${path_data_source}/km_*.* | awk -F' ' '{print $9","$7" "$8","$5" "$6}')
filesList=$(hdfs dfs -ls -t ${path_data_source}/km_*.* | awk -F' ' '{print $8"  -   "$6" "$7"   -  "$5}')
#filesList=$(hdfs dfs -ls -t -h ${path_data_source}/km_*.* | awk -F' ' '{print $9"  -   "$7" "$8"   -  "$5" "$6}')
email_status "$alert_email_addr" "INFO:01: files found today" "INFO:01: Files list in mf:
$filesList"

echo "* Start reading tag files from: /tmp/ " 2>&1 | tee -a ${log_file}

 for tagFile in $(ls /tmp/km_req_*.tag); do
   [ -f "$tagFile" ] || continue
   echo " -----------------------------------------" 2>&1 | tee -a ${log_file}
   echo " *** Tag File: -----> ${tagFile}" 2>&1 | tee -a ${log_file}
   filesCount=0
   sourceFiles=""
   while read sLine; do
      echo "-> Line: ${sLine}" >> ${log_file}
      sFileName=$(echo -e "$sLine" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d',' -f1) 
      echo "    *${sFileName}*" >> ${log_file}
      if [ ! -z "$sFileName" -a "$sFileName" != " " ]; then
         sourceFiles="${sourceFiles} ${path_data_source}/${sFileName}"
         filesCount=$((filesCount+1))
      fi
   done < "$tagFile"
   tagFileName="${tagFile##*/}"

   echo " ------ Copy & delete source files ------" 2>&1 | tee -a ${log_file}
   if [ ${tagFileName} != "" ]; then
     sourceFiles="${sourceFiles} ${path_data_source}/${tagFileName}"
   fi
   echo "Total Files count=${filesCount}" 2>&1 | tee -a ${log_file}
   echo "sourceFiles=${sourceFiles}" >> ${log_file}
   hdfs dfs -cp ${sourceFiles} ${path_hdfs_app_root}/incoming/
   if [ $? != 0 ]; then
         echo "         *****ERROR:01: Source Files copy failed. " 2>&1 | tee -a ${log_file}
         email_status "$alert_email_addr" "ERROR:01: source files copy error" "ERROR:01: Source files copy error"
         hdfs dfs -put -f ${log_file} ${path_hdfs_app_root}/logs/
         exit 103
   fi
   hdfs dfs -rm ${sourceFiles}
   if [ $? != 0 ]; then
         echo "         *****ERROR:01: SOurce File delete failed. " 2>&1 | tee -a ${log_file}
         email_status "$alert_email_addr" "ERROR:01: source files delete error" "ERROR:01: Source files delete error"
         hdfs dfs -put -f ${log_file} ${path_hdfs_app_root}/logs/
         exit 103
   fi
   echo " -----------------------------------------" 2>&1 | tee -a ${log_file}
 done
 
fi
