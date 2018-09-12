#!/bin/sh

#Arguments
#1. VISION_HOME path (to get conf/vision.conf file)
#2.

processDate=`date '+%Y%m%d%H%M%S'`
FROM_EMAIL="kmiry@ABC.com"
ALERT_EMAIL="kmiry@ABC.com"
ALERT_EMAIL="kmiry@ABC.com"
LOG_DIR=/ABC/log
VISION_HOME=$1
ERROR_MSG=""

# Define the functions
log_and_alert() {
    #$1=Message; $2=Subject
    echo "`date +'%m-%d-%Y %H:%M:%S'`:  $1" >> ${LOG_DIR}/vision_events_history_delete_${processDate}.log
    echo -e "`date +'%m-%d-%Y %H:%M:%S'`:\n  $1" | mailx -s "Vision Events History cleanup error: $2" -r "${FROM_EMAIL}" "${ALERT_EMAIL}" <<-EOF
Following error while Events History cleanup activity.
 $2
EOF
}

log() {
    echo "`date +'%m-%d-%Y %H:%M:%S'`:  $1" >> ${LOG_DIR}/vision_events_history_delete_${processDate}.log
}

#Check for the input
if [ -z "$VISION_HOME" ]; then
	ERROR_MSG="ERROR: Arg#1 for Vision Home path is a requred argument."
	echo "$ERROR_MSG"
	log_and_alert "$ERROR_MSG" "Missing Required argument"
	exit 1
else
	if [ -d "$VISION_HOME" ]; then
		if [ -f "$VISION_HOME/conf/vision.conf" ]; then
			HDFSEventsBaseLoc=$(cat $VISION_HOME/conf/vision.conf | grep "vision.factSpan.rawDataLocation" | awk '{print $3}' | tr -d '\r')
			#HDFSEventsBaseLoc=$(echo ${HDFSEventsBaseLoc} | tr -d '\r')
			echo "Raw data location in HDFS: $HDFSEventsBaseLoc"
			if [ -z "$HDFSEventsBaseLoc" ]; then
				ERROR_MSG="ERROR: Raw/Event Data Location property is not set in config file: $VISION_HOME/conf/vision.conf"
				log_and_alert "$ERROR_MSG" "Missing property in config file"
				exit 1
			fi
		else
			ERROR_MSG="ERROR: Config file $VISION_HOME/conf/vision.conf is not found."
			log_and_alert "$ERROR_MSG" "Missing Vision config file"
			exit 1;
		fi
	else
		ERROR_MSG="ERROR: Invalid Vision Home path: $VISION_HOME"
		log_and_alert "$ERROR_MSG" "Invalid Vision Home path"
		echo "$ERROR_MSG"
	fi
fi

export KEYTAB_FILE="/home/kmiry/kmiry.keytab"
export HDFS_PRINCIPAL="kmiry@AD.ABC.COM"

#kinit -k -t ${KEYTAB_FILE} ${HDFS_PRINCIPAL}
#if [ $? != 0 ]
#then
#    # Failed to get a ticket. Log accordingly and exit!
#    log "No valid Kerberos ticket available."
#    exit 1
#fi
#log "Got the kerberos key."

export FROM_EMAIL="kmiry@ABC.com"
export ALERT_EMAIL="kmiry@ABC.com"
export LOG_DIR=/ABC/log

iYear=$(date -d '7 month ago' '+%Y')
iMonth=$(date -d '7 month ago' '+%-m')
#echo "Year=$iYear, Month=$iMonth"

HDFSMonthYearDir="/year=${iYear}/month=${iMonth}"
#echo "Partition path= $HDFSMonthYearDir"

#HDFSDirToDelete=$HDFSEventsBaseLoc$HDFSMonthYearDir
#echo $HDFSEventsBaseLoc$HDFSMonthYearDir

hdfs dfs -rm -R $HDFSEventsBaseLoc$HDFSMonthYearDir

returnCode=$?
if [ ${returnCode} != 0 ]
then
    log_and_alert "Error occurred while deleting the events data in HDFS" "HDFS delete error"
    exit 1
fi
