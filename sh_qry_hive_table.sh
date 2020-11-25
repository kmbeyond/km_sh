
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
    exit 10
fi


--Query beeline result into a string(s)
sJobDates=$(beeline -u "${hive_url}""?mapreduce.job.queuename=${pool_name}"  --outputformat=csv2 --silent=true --showHeader=false --silent=true \
 -e "SELECT start_dt,end_dt FROM kmdb.kmtbl WHERE job_type='STLMNT_TRAN_DLY'")
==> 2020-11-04,2020-11-04

if [[ ${#sJobDates} -ne 21 ]]; then
  echo "ERROR: Check Query that returns dates from kmdb.kmtbl: $sJobDates" 2>&1 | tee -a ${log_file}
  exit 90
fi

#Split it to get each element
IFS=',' read stlmt_from_dt stlmt_to_dt <<<$sJobDates

#OR: Split using cut
stlmt_from_dt=$(echo $sJobDates | cut -f1 -d,)
stlmt_to_dt=$(echo $sJobDates | cut -f2 -d,)

