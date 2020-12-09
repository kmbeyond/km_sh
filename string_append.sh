

s_data=""
if [ -z "$s_data" ]; then s_data="blank";
else s_data=$s_data$'\n'"next";
fi

echo $s_data
if [ -z "$s_data" ]; then s_data="blank";
else s_data=$s_data$'\n'"next";
fi
echo "$s_data"

#Write to a file
echo "$s_data" >> myfile.txt

#--see contents
cat myfile.txt
blank
next

