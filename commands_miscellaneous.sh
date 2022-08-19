
data_on_file=$(cat my_file.txt)
#OR data_on_file=$(<my_file.txt)

#return a random number between 10 & 99
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


#----------------
