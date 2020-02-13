#!/bin/sh

path_hdfs_app_archive=/km/hdfs/path

hdfs dfs -test -e ${path_hdfs_app_archive}/hdfs_run_from_date.txt
if [ $? == 0 ]; then
    #hdfs_from_dt=`hdfs dfs -cat ${path_hdfs_app_archive}/hdfs_run_from_date.txt | cut -d ' ' -f 2 | head -1`
    hdfs_from_dt=`hdfs dfs -cat ${path_hdfs_app_archive}/hdfs_run_from_date.txt | xargs`
    if [ $(expr length "${hdfs_from_dt}") == 10 ]; then
       echo "INFO: Last run day: hdfs_from_dt=$hdfs_from_dt" | tee -a $log_file_local
       hdfs_from_dt=$(date '+%Y-%m-%d' -d "${hdfs_from_dt}+ 1 days")
       echo "INFO: Use next day: hdfs_from_dt=${hdfs_from_dt}" | tee -a $log_file_local
    elif [ "${hdfs_from_dt}" == "" ]; then
      echo "WARN: Blank date, using current date" | tee -a $log_file_local
      hdfs_from_dt=$(date +"%Y-%m-%d")
    else
       echo "ERROR: Invalid run date: ${hdfs_from_dt}" | tee -a $log_file_local
       exit 20
    fi
else
    echo "WARN: Last run config file (${path_hdfs_app_archive}/hdfs_run_from_date.txt) does NOT exist, so setting to current date.." | tee -a $log_file_local
    echo "" | hdfs dfs -put - ${path_hdfs_app_archive}/hdfs_run_from_date.txt
    hdfs_from_dt=$(date +"%Y-%m-%d")
    echo "INFO: hdfs_from_dt=${hdfs_from_dt}" | tee -a $log_file_local
fi

echo "----------------------------------------" | tee -a ${log_file_local}
echo "INFO: hdfs_from_dt=${hdfs_from_dt}" | tee -a ${log_file_local}
echo "----------------------------------------" | tee -a ${log_file_local}




#Update current date
echo $(date +"%Y-%m-%d") | hdfs dfs -put -f - ${path_hdfs_app_archive}/hdfs_run_from_date.txt

