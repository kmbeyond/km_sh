
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
#OR month_on_file=$(echo "${date_on_file}" | awk -F'-' '{print $2}')


if [ $(date '+%m') == "$month_on_file" ]; then
 echo "same Month"
fi





------------------------- date formatting ----------------------------------------
--- 20221102 --> 2022-11-02
my_date_str="20221102"

date -d $my_date_str +"%Y-%m-%d"

echo ${my_date_str:0:4}-${my_date_str:4:2}-${my_date_str:6:2}



--- 2022-11-02 --> 20221102
my_date_str2="2022-11-02"

date -d $my_date_str2 +"%Y%m%d"

IFS=- read y m d <<< $my_date_str2
echo "$y$m$d"

IFS=- read -ra date_array <<< $my_date_str2
echo ${date_array[0]}${date_array[1]}${date_array[2]}

printf '%.4d%.2d%.2d\n' $y $m $d

echo $my_date_str2 | awk -F'-' '{print $1$2$3}'

y=$(echo $my_date_str2 | cut -d "-" -f1)
m=$(echo $my_date_str2 | cut -d "-" -f2)
d=$(echo $my_date_str2 | cut -d "-" -f1)
echo $y$m$d


