

base_dir=`pwd`
logdir=.
AGGR_LOCATION=/home/kmiry/data/test_process
HDFS_LOCATION=/data/res/warehouse/isg/dru_sroct/aia
HDFS_ARCHIVE_LOC=/data/res/warehouse/isg/dru_sroct/aia/archive
HIVE_DATABASE=dru_sroct

processDate=`date '+%Y%m%d%H%M%S'`
logfile=${logdir}/aia_log_${processDate}.log
export FROM_EMAIL="kmiry@ABC.com"
export ALERT_EMAIL="kmiry@ABC.com"
# Define the functions
log_and_alert() {
    #$1=Message; $2=Subject
    echo "`date +'%m-%d-%Y %H:%M:%S'`:  $1" >> $logfile
    echo -e "`date +'%m-%d-%Y %H:%M:%S'`:\n  $1" | mailx -s "AIA Aggregate Report process alert: $2" -r "${FROM_EMAIL}" "${ALERT_EMAIL}" <<-EOF
Following error while loading Aggregate Report data into Hadoop.
 $2
EOF
}

log() {
    echo "`date +'%m-%d-%Y %H:%M:%S'`:  $1" >> $logfile
}


filePostfix=$(date '+%Y_%m_%d_%H_%M_%S')
#current_year=$(date '+%Y')
#current_month=$(date '+%-m')

#Process for each zip file
for filelocation in $AGGR_LOCATION/*.zip;
do

	#filelocation=$AGGR_LOCATION/Aggregate_Report_ABC_2018_6_10.zip

        echo "------------- $filelocation ----------------"
        if [ -e "$filelocation" ]; then

	    temp=$logdir/temp
	    rm -rf $temp || true #KM: used -f 
	    { # try block
	        mkdir -p $temp && cd $temp && cp $filelocation . &&
        	unzip -qq *.zip && find . -type f ! -name '*.csv' -delete &&
	        #sed -i -e 's/\$//g' -e 's/\(\"[^",]\+\),\([^",]*\)/\1\2/g' -e 's/\"//g' -e 1d -e '/^[[:space:]]*$/d;s/[[:space:]]*$//' *.csv && #KM Commented as NO processing

		mergedFileName=$(echo $filelocation | sed -e "s/.zip//" | awk -F'/' '{print $NF}')__${filePostfix}.csv &&
		sed -e '/CarrierReferenceNumber/d;s/[\r]//;/^\s*$/d' *.csv > $mergedFileName && #KM Added for blank lines
		recordsInFile=$(wc -l $mergedFileName | awk '{print $1}') &&
		echo "Records to import: $recordsInFile" &&
		DateOnFirstLine=$(cat $mergedFileName | head -1 | awk -F"," '{print $1}') &&
		iYear=$(date -d $DateOnFirstLine +'%Y') &&
		iMonth=$(date -d $DateOnFirstLine +'%-m') &&
		echo "Date on 1st line on data file=$DateOnFirstLine ; Year=$iYear; Month=$iMonth" &&

		sed -i 's/\(\"[^",]\+\),\([^",]*\)/\1\2/g;s/[\$\"]//g' $mergedFileName &&
		echo "Total records after process: "$(wc -l $mergedFileName | awk '{print $1}') &&
	        echo "Aggregate_Report is cleaned and consolidated" &&
		NewHDFSDir=$HDFS_LOCATION/aggregate_report/year=$iYear/month=$iMonth && #KM added  *** Update for test table ***
		echo newdir=$NewHDFSDir &&
		hdfs dfs -mkdir -p $NewHDFSDir &&

		hdfs dfs -put $mergedFileName $NewHDFSDir && #KM Added
		impala -q "ALTER TABLE $HIVE_DATABASE.aggregate_report ADD IF NOT EXISTS PARTITION (year=$iYear, month=$iMonth) LOCATION '$NewHDFSDir/'" &>>$logfile && #*** Update for test table ***
	        #impala -q "INVALIDATE METADATA $HIVE_DATABASE.aggregate_report" &>>$logfile &&   #*** Update for test table ***
		echo "select count(1) from ${HIVE_DATABASE}.aggregate_report where year=${iYear} and month=${iMonth}"
		recCountInHive=$(impala -q "select count(1) from ${HIVE_DATABASE}.aggregate_report where year=${iYear} and month=${iMonth}" --quiet -B) &&  #*** Update for test table ***
		echo "Records loaded in Hive=$recCountInHive" &&
		if [ $recordsInFile != $recCountInHive ]; then log_and_alert "Records in file & Hive do not match" "Records count mismatch"; fi &&

		#Archive the zip file to HDFS
		hdfs dfs -mkdir -p $HDFS_ARCHIVE_LOC/year=$iYear/month=$iMonth &&
		hdfs dfs -put $filelocation $HDFS_ARCHIVE_LOC/year=$iYear/month=$iMonth &&

		#mv $mergedFileName $"mergedFileName"_COMPLETED &&
		mv $filelocation "$filelocation"_COMPLETED &&
        	log "Aggregate Report updated successfully."
	    } || { # catch block
        	log_and_alert "Error occured during cleaning up of Aggregate Report file"
	    }
	    rm -rf $temp

	else
                echo "* ERROR: No zip files exist"
        fi
done
