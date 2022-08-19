#--------------enable logging
set -x

#--------Append output to file & redirect to console
log_file=my_log_file.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): START JOB" 2>&1 | tee -a ${log_file}


#--------------read file contents into variable
data_on_file=$(cat my_file.txt)
#OR data_on_file=$(<my_file.txt)


#----------return a random number between 10 & 99
shuf -i 10-99 -n 1




#------------zip & unzip
zip km_zipped_file.zip file1.txt file2.txt
zip km_zipped_file.zip source_dir/*
zip -r km_zipped_file.zip .

#unzip
unzip km_zipped_file.zip -d .
unzip km_zipped_file.zip -d km_unzipped_dir/


#--------------split a string
test_string="abc_def_ghi-jkl_mno"

#---using cut
echo $(echo $test_string | cut -d '_' -f 3 ) #split by delimiter _ & return 2nd field/element
=> ghi-jkl


my_string="abcdefg|hijkl"
#--extract string before specific string using substring
echo ${my_string%%|*}
=> abcdefg


#--extract string after a specific string
echo ${my_string##*|}
=> hijkl


#OR echo $(cut -d '_' -f 3 <<< "$test_string")



#---using awk
echo $(echo "${test_string}" | awk -F'_' '{print $3}')
#OR echo $(awk -F'_' '{print $3}' <<< ${test_string})

#split by any character _ or -
echo $(echo "${test_string}" | awk -F'[_-]' '{print $3}')
=> ghi


#--------------email
vi email_template.txt
Hello XFIRST_NAMEX,
Account is setup.

email_template=$(<email_template.txt)
echo "${email_template//XFIRST_NAMEX/Kiran}" > email_kiran.txt

mailx -s "test email" user@domain.com -r donotreply@domain.com < email_kiran.txt


#----------------Read line count from gzip file
zcat my_file.gz | wc -l


#---------------Check if directory exists
if [ ! -d "$path_data_source" ]; then

fi


#----------------Remove chars from a file
sed -e "s/^M//" my_file.csv > my_file_reformatted.csv
sed $'s/[^[:print:]\t]//g' my_file.csv > my_file_reformatted.csv
yank:
:%y a


#list files in all dub-sirectories
ls -l **/*.sh





#------------kerberos
rm ~/.kmuser.keytab
ktutil
addent -password -p kmuser@DOMAIN.COM -k 1 -e rc4-hmac
wkt .kmuser.keytab
exit


kinit kmuser@DOMAIN.COM
#get ticket using keytab
kinit kmuser@DOMAIN.COM -kt ~/.kmuser.keytab

#if getting error: kinit: Client not found in Kerberos database while getting initial credentials

#-----------------sftp
SFTP_URL=oursftpserver.abc.com
SFTP_PORT=12345
KEY_FILE=/home/user1/key_file_w_no_pp
TRANSFER_FILE=/home/user1/data.txt
sftp -oStrictHostKeyChecking=no -oPort=${SFTP_PORT} -oUser=isct-worldpay -oIdentityFile=${KEY_FILE} ${SFTP_URL} <<EOF
  put ${TRANSFER_FILE}
  bye
EOF


#----------------Generate passphrase-less key file for automating sftp
#generate key file embedding passphrase: to connect without using passphrase
openssl rsa -in /home/user1/key_with_pp -out /home/user1/key_file_w_no_pp
=> enter correct passphrase when prompted


