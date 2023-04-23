

#-------remove substring from string
#Example path in HDFS:

/hdfs/path/dir1=1/file1.txt
/hdfs/path/dir1=1/file2.txt

#--single string
d="/hdfs/path/dir1=1/file1.txt"
echo ${d/dir1=/}
=> /hdfs/path/1/file1.txt

#--using sed
echo $(echo $d | sed 's/dir1=//;')
=> /hdfs/path/1/file1.txt


#----multiple substrings
echo $(echo $d | sed 's/dir1=//;s/dir2=//;s/dir3=//')
=> /hdfs/path/1/1.1/1.1.1/file.txt



#---Scenario: directory structure in HDFS due to partitions -NOT COMPLETE
/hdfs/path/dir1=1/dir2=1.1/dir3=1.1.1/file.txt

for d in $(hdfs dfs -ls -d /hdfs/path/* | awk '{print $8}')
do
 echo "$d"
 d2=$(echo $(echo $d | sed 's/dir1=//'))
 #hdfs dfs -mv $d $d2
done;

for d in $(hdfs dfs -ls -d /hdfs/path/*/* | awk '{print $8}')
do
 echo "$d"
 d2=$(echo $(echo $d | sed 's/dir2=//'))
 #hdfs dfs -mv $d $d2
done;

for d in $(hdfs dfs -ls -d /hdfs/path/*/*/* | awk '{print $8}')
do
 echo "$d"
 d2=$(echo $(echo $d | sed 's/s/dir3=//'))
 #hdfs dfs -mv $d $d2
done;

#final output


