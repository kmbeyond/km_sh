


ls -l | awk '{print $9}'
#exclude first row (Ex: total 4) (use grep -v "" for --invert-match)
ls -lt | grep -v "total " | awk '{print $9}'


#------
str_path=/file_path/extract_date=2022-08-18/file.parquet

#--file name from file-path
echo ${str_path##*/}
=> file.parquet
#OR echo $(basename $str_path)

#--directory path 
echo $(dirname $str_path)
=> /file_path/extract_date=2022-08-18



#---HDFS

#--Get full file name
hdfs dfs -ls -t /km/data_archive/ | grep -v "Found" | awk '{print $8}'
hdfs dfs -ls -t /km/data_archive/ | grep -v "Found" | awk '{print $NF}'

#--Get last name either file or directory
basename $(hdfs dfs -ls -t /km/data_archive/ | grep -v "Found" | head -1 | awk '{print $8}')

#--Cut 
hdfs dfs -ls /km/data_archive/ | sed '1d;s/  */ /g' | grep 20200622 | cut -d\  -f8


#------extract specific extract_dtae from path
str_path=/file_path/extract_date=2022-08-18/file.parquet

dir_name=$(dirname $str_path)
echo ${dir_name##*extract_date=}
=> 2022-08-18

