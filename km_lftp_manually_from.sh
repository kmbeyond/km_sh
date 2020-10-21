#!/bin/sh
#USAGE: ./km_lftp_manually_from.sh /data/path

data_loc=$1

#------ functions: START-----------------
function email_status
{
 mailx -s "$2" "$1" <<EOF
$3
EOF
}
#------ functions: END-----------------
alert_email_addr=km@km.com
rundt_tm=$(date +"%Y%m%d_%H%M%S")
log_file=km_lftp_manually_${rundt_tm}_$HOSTNAME.log

echo "$(date +"%Y-%m-%d_%H:%M:%S"): START @ $HOSTNAME ---" 2>&1 | tee -a ${log_file}

if [ "$data_loc" = "" ]; then
 echo "ERROR: *** MISSING INPUT PATH" 2>&1 | tee -a ${log_file}
 exit 111
fi

if [ ! -d $data_loc ]; then
 echo "ERROR:  **** PATH INVALID: $data_loc" 2>&1 | tee -a ${log_file}
 email_status "${alert_email_addr}" "ERROR:Manual File transfer path is invalid" """ERROR: *** PATH INVALID : $data_loc"""
 exit 99;
fi

SFTP_HOST=sftp.abc.com
SFTP_USER=user
SFTP_PASS=pass

#----------PARAMS-----------------
echo "data_loc           = ${data_loc}" 2>&1 | tee -a ${log_file}
echo "alert_email_addr   = ${alert_email_addr}" 2>&1 | tee -a ${log_file}
echo "SFTP_HOST          = ${SFTP_HOST}" 2>&1 | tee -a ${log_file}
echo "SFTP_USER          = ${SFTP_USER}" 2>&1 | tee -a ${log_file}
echo "SFTP_PASS          = ${SFTP_PASS}" 2>&1 | tee -a ${log_file}
#-------------------------------------

echo "Files in: $data_loc" 2>&1 | tee -a ${log_file}
ls -lth $data_loc/ 2>&1 | tee -a ${log_file}

echo "--------- Transfer: pgp-----------------------" 2>&1 | tee -a ${log_file}
counter=1
#for sFile in $(ls $data_loc/); do
for TRANSFER_FILE in $(ls -d $data_loc/*.pgp); do
  echo "[ ${counter} ]: $TRANSFER_FILE" 2>&1 | tee -a ${log_file}
  lftp -e "put -O / ${TRANSFER_FILE}; bye" sftp://${SFTP_USER}:${SFTP_PASS}@${SFTP_HOST}

  #retCode=${PIPESTATUS[0]}
  retCode=$?
  if [ $retCode -eq 0 ]; then
    echo "   --> transferred" 2>&1 | tee -a ${log_file}
    rm -f ${TRANSFER_FILE} 2>&1 | tee -a ${log_file}
  else
    echo "ERROR: File transfer error. Exiting step." 2>&1 | tee -a ${log_file}
    email_status "${alert_email_addr}" "ERROR:Manual File transfer failed" """ERROR:Manual File transfer failed with:
      File=$TRANSFER_FILE
      Error Code: $retCode"""
    #exit 20
  fi
  counter=$((counter+1))
done

echo "-------- Transfer: tag ------------------------" 2>&1 | tee -a ${log_file}
counter=1
for TRANSFER_FILE in $(ls -d $data_loc/*.tag); do
  echo "[ ${counter} ]: $TRANSFER_FILE" 2>&1 | tee -a ${log_file}
  lftp -e "put -O / ${TRANSFER_FILE}; bye" sftp://${SFTP_USER}:${SFTP_PASS}@${SFTP_HOST}

  #retCode=${PIPESTATUS[0]}
  retCode=$?
  if [ $retCode -eq 0 ]; then
    echo "   --> transferred" 2>&1 | tee -a ${log_file}
    rm -f ${TRANSFER_FILE} 2>&1 | tee -a ${log_file}
  else
    echo "ERROR: File transfer error. Exiting step." 2>&1 | tee -a ${log_file}
    email_status "${alert_email_addr}" "ERROR:Manual File transfer failed" """ERROR:Manual File transfer failed with:
      File=$TRANSFER_FILE
      Error Code: $retCode"""
    #exit 20
  fi
  counter=$((counter+1))
done

echo "---------------------------------------------" 2>&1 | tee -a ${log_file}

#echo "Delete files from $data_loc/" 2>&1 | tee -a ${log_file}
#rm -f $data_loc/*
#ls -lt $data_loc/ 2>&1 | tee -a ${log_file}

echo "$(date +"%Y-%m-%d_%H:%M:%S"): END" 2>&1 | tee -a ${log_file}
