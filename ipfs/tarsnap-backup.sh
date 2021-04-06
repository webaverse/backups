#!/bin/sh

# IPFS Backup Strategy

email_address=services@webaverse.com
ipfs_dir=/home/ubuntu/ipfs-backend
logfile=/tmp/tarsnap-backup.log
dirs="/root/.ipfs"

# Navigate to the IPFS working directory.
cd "$ipfs_dir"

# Stop geth.
npm stop

sleep 1

# Take backup.
sudo tarsnap -c \
  -f "$(uname -n)-$(date +%Y-%m-%d_%H-%M-%S)" \
  $dirs > $logfile 2>&1

sleep 1

# Start geth.
npm start

# Send email.
if [ $? -eq 0 ]; then
	subject="Tarsnap backup success"
else
	subject="Tarsnap backup FAILURE"
fi

#mail -s "$subject" $email_address < $logfile

