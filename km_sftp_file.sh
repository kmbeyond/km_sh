#!/bin/sh

#----
echo "------  file sending -----"
SFTP_HOST=ftp.km.com
SFTP_USER=USER1
SFTP_PASS=user1pass

FILE=/path/to/data.txt
lftp -u ${SFTP_USER},${SFTP_PASS} sftp://${SFTP_HOST} <<EOF
put ${FILE}
bye
EOF
echo "-----COMPLETED----"
