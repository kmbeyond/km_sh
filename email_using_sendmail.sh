



sender_email="do-not-reply@abc.com"
recipient_email="km@abc.com"
subject="Report for : ""$(date +"%Y-%m-%d")"
hive_url="jdbc:hive2://hivesrvr.com:10000/default;ssl=true;principal=hive/_HOST@XYZ.COM?mapred.job.queue.name=general"
sql_select="select source, period, count(1) as counts from kmdb.my_table group by source,period order by source,period"
#sql_select="SELECT 'a' as a, 'b' as b, 'c' as c"
header="SOURCE|PERIOD|COUNTS"

(
 echo "From: ${sender_email}"
 echo "Subject: "${subject}""
 echo "Mime-Version: 1.0"
 echo "Content-Type: text/html"
 echo "<html>"
 echo "<style>"
 echo "table, td {border: 1px solid black; border-collapse: collapse;}"
 echo "td {padding: 3px;}"
 echo "th {border: 1px solid black; border-collapse: collapse;}"
 echo "</style>"
 echo "<table><tr>"
 IFS="|" read -ra header_elements <<< "$header"
 for item in "${header_elements[@]}"; do
  echo "<th>${item}</th>"
 done
 echo "</tr>"
 while IFS= read -r line; do
    echo "<tr>"
    IFS='|'
    for item in $line; do
       echo "<td>${item}</td>"
    done
    echo "</tr>"
 done << EOL
$(beeline -u ${hive_url} --showWarnings --verbose  --showHeader=false --outputformat=dsv -e "${sql_select}")
EOL
  echo "</table>"
  echo "</html>" ) |  sendmail -t "${recipient_email}"


