#!/bin/sh

echo "$(date +"%Y-%m-%d %H:%M:%S"): --START--"
log_file=app_log_$(date +"%Y%m%d_%H%M%S")_step.log

nas_loc=/copy/to/nas/

for tagFile in $(ls ${dirName}/app_*.tag); do
   [ -f "$tagFile" ] || continue
     echo "*** Tag File: -----> ${tagFile}" 2>&1 | tee -a ${log_file}
     rowCount=0
     while read sLine; do
       echo " -> Line: ${sLine}" >> ${log_file}
       sFileName=$(echo -e "$sLine" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d',' -f1)
       echo "    *${sFileName}*" >> ${log_file}
       if [ ! -z "$sFileName" -a "$sFileName" != " " ]; then
         cp ${dirName}/$sFileName ${nas_loc}/staging/
         if [ $? != 0 ]; then
           echo "         *****ERROR:01:File Transfer job: Source Files copy failed. " 2>&1 | tee -a ${log_file}
           email_status "${alert_email_addr}" "ERROR:01:File Transfer job: Source files copy to staging error" "ERROR:01:File Transfer job: CSIG Source files copy to staging error"
           exit 103
         fi
         rowCount=$((rowCount+1))
       fi
     done < "$tagFile"
     #tagFileName="${tagFile##*/}"
     echo " -----------------------------------------" 2>&1 | tee -a ${log_file}
done


