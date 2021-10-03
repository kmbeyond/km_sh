

counter=1
datafile=datafile.txt
while [[ $counter -le 1000 ]]
do
 #For format : 001, 002, ...
 #counter=$(echo $counter | awk '{printf "%03d\n", $0;}')
 #echo "-> $counter"
 echo "$counter" >> $datafile
 counter=$((counter+1))	 # increment
done

ls -lh $datafile

#------output file size
till 1000 => 3.9K
till 5000 => 28K
till 10000 => 48K
till 100000 => 576K

#----create multiple copies of a file
counter=1
datafile=datafile.txt
while [[ $counter -le 1000 ]]
do
 cp $datafile ${counter}_$datafile
 counter=$((counter+1)) #increment
done


