#!/bin/sh

#----
echo "------  file sending -----"
SFTP_HOST=ftp.km.com
SFTP_USER=USER1
SFTP_PASS=user1pass

FILE=/path/to/data.txt
lftp -u ${SFTP_USER},${SFTP_PASS} sftp://${SFTP_HOST} <<EOF
put ${FILE}
bye
EOF
echo "-----COMPLETED----"




#----sftp all files in a HDFS dir

path_hdfs_app_root="/lake/kinvent"
archiveDirName=$(date '+%Y-%m-%d')

hdfs dfs -mkdir ${path_hdfs_app_root}/outgoing-archive/${archiveDirName}
rm /tmp/CSIG_aud*.csv
hdfs dfs -get ${path_hdfs_app_root}/outgoing/kinv_*.csv /tmp/
chmod 777 /tmp/kinv_*.csv

for csvFile in /tmp/kinv_*.csv; do
   [ -f "$csvFile" ] || continue
 echo "File: $csvFile"
#         lftp -u ${SFTP_USER},${SFTP_PASS} sftp://${SFTP_HOST} <<EOF
#         put ${csvFile}
#         bye
#EOF
          sleep 1
done
hdfs dfs -mv ${path_hdfs_app_root}/outgoing/kinv_*.csv ${path_hdfs_app_root}/outgoing-archive/${archiveDirName}  2>&1 | tee -a ${log_file}
hdfs dfs -rm ${path_hdfs_app_root}/outgoing/kinv_*.csv
rm /tmp/kinv_*.csv



