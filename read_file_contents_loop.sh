#!/bin/sh

#---read file contents as plain text
while read sline
do
 echo "$sline"
done < "dc_mapping.config"


#---read file contents by delimiter
#Source file: dc_mapping.config
src|file|dest
src1|file1.txt|dest1
src2|file2.txt|dest2

while IFS='|' read -r source file dest
do
 echo "-->$source - $file - $dest"
done < "dc_mapping.config"
=>output:
-->src1 - file1.txt - dest1
-->src2 - file2.txt - dest2



#---loop through tag files for each file name & read its contents
tag_file.tag
/km/file1.txt
/km/dir1
/km/file2.txt

echo "$(date +"%Y-%m-%d %H:%M:%S"): --START--"
log_file=app_log_$(date +"%Y%m%d_%H%M%S")_step.log

nas_loc=/copy/to/nas/

for tagFile in $(ls ${nas_loc}/*.tag); do
   [ -f "$tagFile" ] || continue
     echo "*** Tag File: -----> ${tagFile}" 2>&1 | tee -a ${log_file}
     rowCount=0
     while read sLine; do
       echo " -> Line: ${sLine}" >> ${log_file}
       sFileName=$(echo -e "$sLine" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d',' -f1)
       echo "    --->${sFileName}" >> ${log_file}
       if [ ! -z "$sFileName" -a "$sFileName" != " " ]; then
         cp ${dirName}/$sFileName ${nas_loc}/staging/
         rowCount=$((rowCount+1))
       fi
     done < "$tagFile"
     #tagFileName="${tagFile##*/}"
     echo " -----------------------------------------" 2>&1 | tee -a ${log_file}
done

