
echo "$(date +"%Y-%m-%d %H:%M:%S")"
=> 2022-08-19 17:04:38
today_dt=$(date +"%Y-%m-%d")

echo "$(date +"%Y-%m-%d")" > my_date_file.txt
date_on_file=$(cat my_date_file.txt)


#Add days to a date
next_day_dt=$(date +"%Y-%m-%d" -d "${date_on_file}+ 1 days")
#OR next_day_dt=`date +"%Y-%m-%d" -d "${date_on_file}+ 1 days"`
yesterday_dt=$(date +"%Y-%m-%d" -d "$date_on_file- 1 days")

#compare day
today_day=$(date +'%A')
if [ "$today_day" == "Sunday" ]; then
   echo "Today is Sunday."
else
   echo "Not Sunday"
fi


#check time (Take previous day if current time is before 4pm
now_hour=$(date +'%H')
if [ $now_hour -lt 16 ]; then
   echo "Before 4pm."
   job_start_dt=`date +"%Y-%m-%d" -d "-1 days"`
else
   echo "After 4pm"
   job_start_dt="$(date +'%Y-%m-%d')"
fi

#get date from file & extract part of date

month_on_file="$(echo $date_on_file | cut -d '-' -f 2 )"
#OR month_on_file=$(echo "${date_on_file}" | awk -F'[-.]' '{print $2}')

if [ $(date '+%m') == "$month_on_file" ]; then
 echo "same Month"
fi

