

-------------------------yarn
yarn application -list -appStates ALL | grep oozie-job-name
yarn application -list -appStates FINISHED | grep oozie-job-name
#NO USE OF:  -appOwner s1p.abda_ingest 

yarn application -list -appStates ALL | grep 'KM Spark job'

yarn logs -applicationId application_1660287592430_1067 > application_1660287592430_1067.log

yarn logs -applicationId <Application ID> -containerId <Container ID> -size 1000

yarn logs -applicationId <Application ID> -show_container_log_info


------------------------oozie
oozie job -oozie https://bda6node10.infoftps.com:11443/oozie -config /opt/scripts/data_comm/oozie/km_test_hive/job.properties -run
oozie job -oozie https://bda6node10.infoftps.com:11443/oozie -kill 0005097-210813023528696-oozie-oozi-W
oozie job -oozie https://bda6node10.infoftps.com:11443/oozie -rerun 0000027-220909031034651-oozie-oozi-W

oozie job -oozie https://bda6node10.infoftps.com:11443/oozie -log 0005077-210813023528696-oozie-oozi-W > 0005077-210813023528696-oozie-oozi-W.log

--config
----xml
<job-tracker>${jobTracker}</job-tracker>
<name-node>${nameNode}</name-node>

----job.properties
nameNode=hdfs://bda1-ns
jobTracker=yarnRM


--------------------------


