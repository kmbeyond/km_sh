


ls -l | awk '{print $9}'
#exclude first row (Ex: total 4) (use grep -v "" for --invert-match)
ls -lt | grep -v "total " | awk '{print $9}'

#---HDFS

#--Get full file name
hdfs dfs -ls -t /km/data_archive/ | grep -v "Found" | awk '{print $8}'
hdfs dfs -ls -t /km/data_archive/ | grep -v "Found" | awk '{print $NF}'

#--Get last name either file or directory
basename $(hdfs dfs -ls -t /km/data_archive/ | grep -v "Found" | head -1 | awk '{print $8}')

#--Cut 
hdfs dfs -ls /km/data_archive/ | sed '1d;s/  */ /g' | grep 20200622 | cut -d\  -f8


