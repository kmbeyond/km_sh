
hive_url="jdbc:hive2://mybdanode.com:10000/default;ssl=true;principal=hive/_HOST@myad"
pool_name="general"
db_hive="kmdb"
dt_today=$(date '+%Y-%m-%d')
processDate=$(date '+%Y-%m-%d_%H_%M_%S')
log_file=/tmp/km_log_${processDate}_$HOSTNAME.log
path_hdfs_logs="/km/bd/"



#--Query beeline result (one row) into a string

sql_row=$(beeline -u "${hive_url}" --silent=true --showHeader=false --outputformat=csv \
 -e "set mapreduce.job.queuename=${pool_name}; SELECT * FROM ${db_hive}.km_mrchnt LIMIT 1 ")

echo ${sql_row}
=> '1','ABC COMPANY, INC','123 Main St'

#remove quotes using any of below:
echo ${sql_row//\'/}
#OR echo $sql_row | tr -d "'"
#OR echo $(echo $sql_row | sed -r "s/'//g")
=> 1,ABC COMPANY, INC,123 Main St

sql_row2=${sql_row//\'/}

#Split it to get each element
IFS=',' read col1 col2 col3 <<<$sql_row2

#OR: Split using cut
col1=$(echo $sql_row2 | cut -f1 -d,)
#OR: col1=$(cut -f1 -d',' <<< "$sql_row2");

col2=$(echo $sql_row2 | cut -f2 -d,)


#--Query to get multple rows
sql_rows=$(beeline -u "${hive_url}" --silent=true --showHeader=false --outputformat=csv \
 -e "set mapreduce.job.queuename=${pool_name}; select * from ${db_hive}.km_mrchnt")

#split by new-line into array
IFS=$'\n' data_array=($sql_rows)

for str in "${data_array[@]}"; do
   IFS=',' read col1 col2 col3 <<<$str;
   echo " -> $str -> $col1 $col2 $col3"
done
=>
 -> '1','ABC COMPANY, INC','123 Main St' -> '1' 'ABC COMPANY  INC','123 Main St'
 -> '2','XYZ COMPANY INC.','456' -> '2' 'XYZ COMPANY INC.' '456'
 -> '3','WALMART - 2345','Alpha Lane' -> '3' 'WALMART - 2345' 'Alpha Lane'





#--insert into table
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
