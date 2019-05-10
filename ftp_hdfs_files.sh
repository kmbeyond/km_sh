#!/bin/sh

processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/km_${processDate}_$HOSTNAME.log

path_hdfs_app_root="/km/bd"
archiveDirName=$(date '+%Y-%m-%d')

hdfs dfs -mkdir ${path_hdfs_app_root}/outgoing-archive/${archiveDirName}
rm /tmp/CSIG_aud*.csv
hdfs dfs -get ${path_hdfs_app_root}/outgoing/km_aud*.csv /tmp/
chmod 777 /tmp/km_aud*.csv
for csvFile in /tmp/km_aud*.csv; do
   [ -f "$csvFile" ] || continue
 echo "File: $csvFile"
#         lftp -u ${SFTP_USER},${SFTP_PASS} sftp://${SFTP_HOST} <<EOF
#         put ${csvFile}
#         bye
#EOF
          sleep 1
done
hdfs dfs -mv ${path_hdfs_app_root}/outgoing/km_aud*.csv ${path_hdfs_app_root}/outgoing-archive/${archiveDirName}  2>&1 | tee -a ${log_file}
hdfs dfs -rm ${path_hdfs_app_root}/outgoing/km_aud*.csv
rm /tmp/CSIG_aud*.csv
