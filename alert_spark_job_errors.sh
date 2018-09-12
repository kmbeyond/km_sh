#!/bin/bash
echo "-------- Time : " `date '+%Y-%m-%d %H:%M:%S'` " ---------"

user_name="kmiry"
keytab_file="/home/""$user_name""/""$user_name"".keytab"
hdfs_principal="""$user_name""@AD.ABC.COM"

#user_name="rtalab_vision"
#user_name="auqbvsn"
#keytab_file="/home/kmiry/kerberos/rtalab_vision.keytab"
#hdfs_principal="""$user_name""@HADOOPQA.ABC.COM"

JOB_NAME="Consume Vision span events"
application_user="auqbvsn"
#ALERT_EMAIL_TO="kmiry@ABC.com"
ALERT_EMAIL_TO="kmiry@ABC.com"

kinit -k -t ${keytab_file} ${hdfs_principal}
if [ $? != 0 ]
then
    # Failed to get a ticket. Log accordingly and exit!
    #log "No valid Kerberos ticket available."
	mailx -s "Error in generating ticket" $ALERT_EMAIL_TO <<-EOF
					Couldn't get valid Kerberos ticket available for job $JOB_NAME.
					EOF
    exit 1
fi

#log "Got the kerberos key."

ALERT_EMAIL_CC="kmiry@ABC.com"
ALERT_EMAIL_FROM="kmiry@ABC.com"
ALERT_SUBJECT_RUN="Alert! Spark job $JOB_NAME is not running"
ALERT_MSG_RUN="Hi team,
The following job(s) is not running.
$JOB_NAME

Please work on it ASAP."

LOG_DIR=/ABC/log
#processDate=`date '+%Y%m%d%H%M%S'`
ALERT_SUBJECT_ERR="Alert! Spark job has logged errors"

ALERT_SUB_NODATA="Alert! Spark job has no event flow"
ALERT_MSG_NODATA="Hi team,
The following job(s) has no event flow in.
$JOB_NAME

Please check."

echo "*** Checking if yarn job running ***"
re='^[0-9]*$'
for line in `yarn application -list | grep "\<$JOB_NAME\>.*\<$application_user\>" | awk -F'\t' '{print $6}' | wc -l`; do
#for line in `yarn application -list | grep "$application_id" | awk -F' ' '{print $9}' | wc -l`; do
	if [[ $line =~ ^[0-9]*$ ]]; then
		if [[ $line -gt 1 ]]; then
			echo " More than 1 job ($JOB_NAME) are running.";
			mailx -s "More than 1 jobs are running" -c $ALERT_EMAIL_CC $ALERT_EMAIL_TO <<-EOF
					More than 1 following job(s) are running:
					-$JOB_NAME
					
					EOF
		else
			for line2 in `yarn application -list | grep "\<$JOB_NAME\>.*\<$application_user\>" | awk -F'\t' '{print $6}'`; do
				if [ $line2 -lt 25 ];
				then
					if [[ $line2 == "RUNNING" ]]; then
						echo " -> $JOB_NAME job is running.";
					else
						echo " -> $JOB_NAME job is NOT Running.";
						mailx -s "$ALERT_SUBJECT_RUN" -c $ALERT_EMAIL_CC $ALERT_EMAIL_TO <<-EOF
					$ALERT_MSG_RUN
					EOF
					fi
				fi
			done
		fi
	fi
done

echo "*** Checkng for errors ***"
latestError=`grep "ERROR" \`find "$LOG_DIR"/ -cmin -5 -type f\` < /dev/null | tail -1`
if [[ $latestError != "" ]];
then
	echo " -> $JOB_NAME has got few errors.";
        mailx -s "$ALERT_SUBJECT_ERR" -c $ALERT_EMAIL_CC $ALERT_EMAIL_TO <<-EOF
Hi team,
The following job(s) generated some errors.
Job: $JOB_NAME
File: 
`grep -l "ERROR" \`find "$LOG_DIR"/ -cmin -5 -type f\` < /dev/null`

Latest Error line:
$latestError

Please work on it ASAP.
EOF
else
	echo " -> $JOB_NAME has NO errors in last 5 minutes.";
fi

echo "*** Checkng if events are flowing in ***"
SRCH_EVENT_DATA="It seems there are no events flowing in. Received an empty RDD"

datePattern="[0-9]\{2\}/[0-9]\{2\}/[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}"
latestMsg=`grep -h "$SRCH_EVENT_DATA" \`find "$LOG_DIR"/ -cmin -5 -type f\` < /dev/null | tail -1`

if [[ $latestMsg != "" ]]; then
	#echo `grep -h "$SRCH_EVENT_DATA" \`find "$LOG_DIR"/ -cmin -5 -type f\` < /dev/null | tail -1 | grep -o "$datePattern"`
	latestDateTime=20`echo $latestMsg | grep -o "$datePattern"`

	if [[ $(($(date +%s) - $(date +%s -d "$latestDateTime"))) -le 300 ]];
	then
			echo " -> $JOB_NAME has got no event data.";
			mailx -s "$ALERT_SUB_NODATA" -c $ALERT_EMAIL_CC $ALERT_EMAIL_TO <<-EOF
	Hi team,
	The following job(s) has no event flow in.
	Job: $JOB_NAME
	File: `(grep -l "$SRCH_EVENT_DATA" \`find "$LOG_DIR"/ -cmin -5 -type f\`  /dev/null | tail -1)`
	
	Latest Alert: $latestMsg

	Please check.
	EOF
	else
			echo " -> $JOB_NAME has got event data.";
	fi
fi
