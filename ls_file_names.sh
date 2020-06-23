


ls -l | awk '{print $9}'


#---HDFS command output
hdfs dfs -ls /km/data_archive/ | grep 20200622 | awk '{print $8}'


hdfs dfs -ls /km/data_archive/ | sed '1d;s/  */ /g' | grep 20200622 | cut -d\  -f8


