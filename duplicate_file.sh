
file_name=$1
times=$2

rundt_tm=$(date +"%Y%m%d_%H%M%S")
log_file=filecopy_${rundt_tm}_$HOSTNAME.log

echo "------- INPUT ARGS ----" 2>&1 | tee -a ${log_file}
echo "-----------------------" 2>&1 | tee -a ${log_file}
echo "file_name : $file_name" 2>&1 | tee -a ${log_file}
echo "times     : $times" 2>&1 | tee -a ${log_file}
echo "-----------------------" 2>&1 | tee -a ${log_file}

extension="${file_name##*.}"
filename="${file_name%.*}"

echo "filename  : $filename" 2>&1 | tee -a ${log_file}
echo "extension : $extension" 2>&1 | tee -a ${log_file}

counter=1
while [ $counter -le $times ]
do
  echo "-> $counter: " 2>&1 | tee -a ${log_file}
  cp $file_name ${filename}_${counter}.${extension}
  counter=$((counter+1))
done

