

counter=1
datafile=datafile.txt
while [ $counter -le 5 ]
do
 filenum=$(echo $counter | awk '{printf "%03d\n", $0;}')
 echo "write $filenum"
 echo "$filenum" >> $datafile
 counter=$((counter+1))	 # increment
done

cat $datafile

#------output
$ cat $datafile
001
002
003
004
005
