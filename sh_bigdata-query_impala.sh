



imp_deamon="bdanode001"
pool_name="general"
db_hive="kmdb"
dt_today=$(date '+%Y-%m-%d')
processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/km_log_${processDate}_$HOSTNAME.log
path_hdfs_logs="/km/bd/"


if [ "$imp_deamon" = "" ]; then imp_i="-i ${imp_deamon}"; else imp_i=""; fi

#impala-shell --ssl -i ${imp_deamon} -q """
impala-shell --ssl  "$imp_i" -q """
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


#------------query impala & capture output to string
for data_row in $(impala-shell --ssl -i "$imp_deamon" --quiet -q "set request_pool=general; INVALIDATE METADATA data_comm.cnvr_tran_stg1_dly; SELECT * FROM data_comm.cnvr_tran_stg1_dly;" --output_delimiter="|" -B ); do
 echo "$data_row"
done

#result into a variable
impala_result=$(impala-shell --ssl -i "$imp_deamon" --quiet -q "set request_pool=general; INVALIDATE METADATA data_comm.cnvr_tran_stg1_dly; SELECT * FROM data_comm.cnvr_tran_stg1_dly;" --output_delimiter="|" -B )

#loop through rows
for row in $(echo $impala_result);
do
  col2=$(echo "$row" | awk -F'|' '{print $2}')
  echo "$row -> $col2"
done

#split result into array & loop through array
array=(${impala_result//\\n/ })
for element in "${array[@]}"; do
  echo $element;
done

