#!/bin/sh


hive_url="jdbc:hive2://bda6node10.abc.com:10000/default;ssl=true;principal=hive/_HOST@BDA6.abc.COM"
pool_name=hermonization


cg_req_data=$(beeline -u "${hive_url}" --silent=true --showHeader=false --outputformat=csv \
 -e "set mapreduce.job.queuename=${pool_name}; SELECT req.id,req.tpenddate,req.merchants,ra.audience_id FROM db.cg_request req JOIN db.cg_request_audience ra ON ra.id=req.id AND ra.process_date=req.process_date WHERE req.process_date IN (SELECT MAX(b.process_date) FROM db.cg_request b)")
cg_req_data=$(echo $cg_req_data | sed -r "s/'//g")

for str in "${cg_req_data// / }"; do
   sId=$(cut -f1 -d',' <<< "$str");
   sTPEnddate=$(cut -f2 -d',' <<< "$str");
   sMerchants=$(cut -f3 -d',' <<< "$str");
   sAudId=$(cut -f4 -d',' <<< "$str");

   echo " -> $sId $sTPEnddate $sMerchants $sAudId"

done


