



imp_deamon="bda1node17"
pool_name="general"
db_hive="kmdb"
dt_today=$(date '+%Y-%m-%d')
processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/km_log_${processDate}_$HOSTNAME.log
path_hdfs_logs="/km/bd/"

#impala-shell --ssl -i ${imp_deamon} -q """
impala-shell --ssl  -q """
set request_pool=${pool_name};
REFRESH ${db_hive}.tbl_ext_tbl1;
REFRESH ${db_hive}.tbl_ext_tbl2;


INSERT OVERWRITE TABLE ${db_hive}.tbl_ext_tbl2 PARTITION (extract_date='${dt_today}')
  SELECT * FROM ${db_hive}.tbl_ext_tbl1;
  
REFRESH ${db_hive}.tbl_ext_tbl2;
 """ 2>&1 | tee -a  ${log_file}

retCode=${PIPESTATUS[0]}
if [ $retCode -ne 0 ]; then
    echo "****** ERROR: SQL for Peer compliance data" 2>&1 | tee -a ${log_file}
    #email_status "${alert_email_addr}" "ERROR:TAC:" "ERROR:TAC: "
    hdfs dfs -put -f ${log_file} ${path_hdfs_logs}/
    exit 10
fi


