#!/bin/sh
# -----------------------------------------------------------------------------------------------------------------------------------------
# Script Name: km_02_hdfs_log_file_merge.sh
# Author : Kiran Miryala
# Date   : 
# Description of Script/Process: To merge the Siebel log data into Hive by yyyy_MM_dd_HH_mm
# -----------------------------------------------------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------------------------------
# Modification History
# ------------------------------------------------------------------------------------------------------------------
# Modified By              Date        Version          Comments
# ------------------------------------------------------------------------------------------------------------------
#  Kiran Miryala    19/Dec/2015  1.0				1.To merge the Siebel log data into Hive
#-------------------------------------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------------------------------------------------------
# General Flow (steps):
# -----------------------------------------------------------------------------------------------------------------------------------------
# 1) Create the directory in Hive warehouse based on time yyyy_MM_dd_HH_mm
# 2) Move the data created by Spark Streaming from second level to minute level
# -----------------------------------------------------------------------------------------------------------------------------------------


# Dependencies: None

#
#. /d01/app/marketing/scripts/integration_env.sh

#----Local Variable Declarations------
#Using current datetime for testing
#CUR_DATE=$1
CUR_DATE=2017_02_18_12_25
#CUR_DATE=`date +%Y_%m_%d_%H_%M`

PRC_SRC_DIR=/home/kiran/km/km_hadoop_op/op_spark/op_streaming/STRM_$CUR_DATE
PRC_DEST_DIR=/home/kiran/km_hadoop_fs/warehouse/kmdb.db/txns_cust/txn_dt=`echo $CUR_DATE | cut -b 1-10 | sed -e "s/_/-/g"`
MERGE_LOG_DIR=/home/kiran/km/km_hadoop_op/merge_log/
MERGE_LOG_FILE=merge_$CUR_DATE.log
MERGE_START_DT=`date +%Y-%m-%d' '%H:%M:%S`
MERGE_END_DT=''
#------------------------------------------------------------------------------------


# Merge the data
echo "--------------------------------------------------------------------------------" >> $MERGE_LOG_DIR$MERGE_LOG_FILE
echo "START MERGE PROCESS AT " `date +%Y-%m-%d' '%H:%M:%S` >> $MERGE_LOG_DIR$MERGE_LOG_FILE
echo "--------------------------------------------------------------------------------" >> $MERGE_LOG_DIR$MERGE_LOG_FILE
echo START MERGE PROCESS AT `date +%Y-%m-%d' '%H:%M:%S`
# --------------------------------------------------------------------------------------------------------------------
echo "Initialize process..." >> $MERGE_LOG_DIR$MERGE_LOG_FILE
# --------------------------------------------------------------------------------------------------------------------
echo create directory: $PRC_DEST_DIR
echo "Create directory: "$PRC_DEST_DIR >> $MERGE_LOG_DIR$MERGE_LOG_FILE
hdfs dfs -mkdir $PRC_DEST_DIR

echo merge directory $PRC_SRC_DIR'*/pa* ->' $PRC_DEST_DIR/$CUR_DATE.txt
echo "Merge directory " >> $MERGE_LOG_DIR$MERGE_LOG_FILE
hdfs dfs -getmerge $PRC_SRC_DIR*/pa* $PRC_DEST_DIR/$CUR_DATE.txt

MERGE_END_DT=`date +%Y-%m-%d' '%H:%M:%S`
echo End Of Inserting Records into Siebel $MERGE_END_DT
echo "--------------------------------------------------------------------------------" >> $MERGE_LOG_DIR$MERGE_LOG_FILE
echo "END MERGE PROCESS AT "`date +%Y-%m-%d' '%H:%M:%S`  >> $MERGE_LOG_DIR$MERGE_LOG_FILE
echo "--------------------------------------------------------------------------------" >> $MERGE_LOG_DIR$MERGE_LOG_FILE
# ---------------------------------------------------------------------------------------------------------------------



