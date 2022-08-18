#!/bin/sh

-----Iterate files in a directory
#rename files by replacing %20 with _
cd test
for fileName in $(ls);
do
 fileNameNew2=$(echo $fileName | sed -e "s/%20/_/g")
 echo "$fileName -> $fileNameNew2"
 if [[ "$fileName" == "$fileNameNew2" ]]; then
  echo "--> No change, so skip"
 else
  mv "$fileName" "$fileNameNew2"
  echo "--> Rename"
 fi
done


---find & iterate files/directories
--directories--
find csig/* -maxdepth 0 -type d  | xargs -n 1 basename
for dirName in $(find ~/csig/* -maxdepth 0 -type d | xargs -n 1 basename); do echo ${dirName}; done

#To remove path & get just dir name
baseDirName=$(basename "$dirName")

--Files--
find csig/* -maxdepth 0 -type f | xargs -n 1 basename
find csig/* -maxdepth 0 -type f  -name "*.csv" 
#Using find
for fileName in $(find ~/csig/* -maxdepth 0 -type f | xargs -n 1 basename); do
 echo "Full Name: ${fileName}  -> $(basename "${fileName}")"
done

#Using ls (use ls only if known file ext or use -f to get file only)
for fileName in $(ls ~/csig/*.json); do
 [ -f "$fileName" ] || continue
 echo "Full Name: ${fileName}  -> $(basename "${fileName}")"
done


#find older files (Older than 1000 days)
find ./* -type f -mtime +1000 -exec ls -ltr {} \;
#remove older files with extension .gz (Older than 1000 days)
find ./* -type f -mtime +1000 -name "*.gz" -exec rm -r {} \;
