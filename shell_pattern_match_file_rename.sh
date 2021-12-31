

#get file_num from file attern
fileNameNew1="abc%20def%20Part12.mp3"

#using sed
echo $(echo "$fileNameNew1" | sed -E 's|^[A-Za-z0-9%_]+Part([0-9]+).mp3|\1|')

#using BASH_REMATCH
fileNameNew1="abc%20def%20Part12.mp3"
[[ $fileNameNew1 =~ ^[A-Za-z0-9%_]+Part([0-9]+).mp3 ]]
echo "${BASH_REMATCH[1]}"




#Scenario: rename files in following pattern
#Current file name: abc%20def%20Part12.mp3
#new file name:  abc_def_012.mp3


for fileName in $(ls);
do
 fileNameNew1=$(echo $fileName | sed -e "s/%20/_/g")
 #echo "$fileName -> $fileNameNew1"
 file_num=$(echo "$fileNameNew1" | sed -E 's|^[A-Za-z0-9_]*Part([0-9]+).mp3|\1|')
 file_num_new=$(printf "%03d" "$file_num")
 fileNameNew2=$(echo $fileNameNew1 | sed -e "s/Part$file_num/$file_num_new/g")
 #echo "$fileNameNew1 -> $fileNameNew2"
 echo "$fileName -> $fileNameNew2"
 if [[ "$fileName" == "$fileNameNew2" ]]; then
  echo "--> No change, so skip"
 else
  mv "$fileName" "$fileNameNew2"
 fi
done

