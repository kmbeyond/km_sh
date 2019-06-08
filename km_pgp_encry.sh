#!/bin/sh

echo "--START--"
pwd

echo "----"
#source ~/.bashrc
#source ~/.bash_profile
echo "gpg keys= $(gpg -k)"

gpg --version
echo "---- set GNUPGHOME to load keys when script run from Oozie"
export GNUPGHOME=/home/km/.gnupg

/usr/bin/gpg -k

echo "PATH= $PATH"

echo "--Generate pgp encrypted file--"
runtm=$(date +"%H%M%S")
rundt=$(date +"%Y%m%d")

hdfs dfs -cat ${hdfsfile} | gpg --batch --trust-model always --encrypt -a -r pgp_id -r pgp_id2 -o ${outdir}/enc_file_${runtm}_${rundt}.txt.pgp

echo "--END--"
