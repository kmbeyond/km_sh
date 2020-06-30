
hive_url="jdbc:hive2://mybdanode.com:10000/default;ssl=true;principal=hive/_HOST@myad"
pool_name="general"
db_hive="kmdb"
dt_today=$(date '+%Y-%m-%d')
processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/km_log_${processDate}_$HOSTNAME.log
path_hdfs_logs="/km/bd/"

beeline -u "${hive_url}""?mapreduce.job.queuename=${pool_name}" --silent \
 -e """
INSERT OVERWRITE TABLE ${db_hive}.tbl_ext_tbl2 PARTITION (extract_date='${dt_today}')
  SELECT * FROM ${db_hive}.tbl_ext_tbl1;

 """ 2>&1 | tee -a  ${log_file}

retCode=${PIPESTATUS[0]}
if [ $retCode -ne 0 ]; then
    echo "****** ERROR: SQL for Peer compliance data" 2>&1 | tee -a ${log_file}
    #email_status "${alert_email_addr}" "ERROR:TAC:" "ERROR:TAC: "
    hdfs dfs -put -f ${log_file} ${path_hdfs_logs}/
    exit 10
fi

