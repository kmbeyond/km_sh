#!/bin/sh

localDirName="."
path_hdfs_app_root=""
alert_email_addr="km@km.com"

#XSFTP_HOST=mft.km.com
SFTP_HOST=qamft.km.com
SFTP_PASS=pass1
SFTP_USER=kmuser

processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/km_sftp_test_${processDate}_$HOSTNAME.log

#-------- functions: Start --------
function email_status
{
to_address="$1"
subject="$2"
message="$3"
mailx -s "${subject}" "${to_address}" <<EOF
$message
EOF
}
#------- functions: End


#sftp
echo "------ sftp -------" 2>&1 | tee -a ${log_file}
#if [ $(hdfs dfs -ls ${path_hdfs_app_root}/CSIG_resp_*.tag | wc -l) -gt 0 ];
if [ $(ls -lt ${localDirName}/kinv_*.tag | wc -l) -gt 0 ];

then
echo "----- sftp START -----" 2>&1 | tee -a ${log_file}
#rm -f /tmp/kinv_*.*
fileCount=0
#hdfs dfs -get ${path_hdfs_app_root}/kinv_*.tag /tmp/
cp ${localDirName}/kinv_*.tag /tmp/
for tagFile in $(ls /tmp/kinv_*.tag); do
   [ -f "$tagFile" ] || continue
   echo "*** Tag File: -----> ${tagFile}" 2>&1 | tee -a ${log_file}

   while read sLine; do
      echo " -> Line: ${sLine}" 2>&1 | tee -a ${log_file}
      if [ ! -z "$sLine" -a "$sLine" != " " ]; then
         #hdfs dfs -get ${path_hdfs_app_root}/${sLine} /tmp/
         cp ${localDirName}/${sLine} /tmp/
         if [ $? == 0 ]; then
          lftp -u ${SFTP_USER},${SFTP_PASS} sftp://${SFTP_HOST} <<EOF
          put /tmp/${sLine}
          bye
EOF

          fileCount=$((fileCount+1))
          #echo "          Coping to: ${path_hdfs_app_root}/outgoing-archive " 2>&1 | tee -a ${log_file}
          #hdfs dfs -mv ${path_hdfs_app_root}/outgoing/${sLine} ${path_hdfs_app_root}/outgoing-archive/   2>&1 | tee -a ${log_file}
          #echo "          Deleting: ${path_hdfs_app_root}/outgoing/${sLine}" 2>&1 | tee -a ${log_file}
          #hdfs dfs -rm ${path_hdfs_app_root}/outgoing/${sLine}  2>&1 | tee -a ${log_file}
         fi
      fi
   done < "$tagFile"
   echo " Total files: $fileCount" 2>&1 | tee -a ${log_file}
   tagFileName="${tagFile##*/}"
#   sleep $((fileCount*1))m
   lftp -u ${SFTP_USER},${SFTP_PASS} sftp://${SFTP_HOST} <<EOF
   put ${tagFile}
   bye
EOF
   rm -f $tagFile
   echo " -----------------------------------------" 2>&1 | tee -a ${log_file}
done
echo "----- sftp COMPLETE -----" 2>&1 | tee -a ${log_file}
else
  echo "--- ERROR: No response tag file found, so skipping sftp. ---" 2>&1 | tee -a ${log_file}
  email_status "$alert_email_addr" "ERROR:04: Tag file is missing for sftp" "ERROR:04: Tag file is missing for sftp"
fi
