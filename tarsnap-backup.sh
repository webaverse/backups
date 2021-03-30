#!/bin/sh

# Default Backup Strategy

email_address=services@webaverse.com
logfile=/tmp/tarsnap-backup.log
dirs="/"

# Take backup.
sudo tarsnap -c \
  -f "$(uname -n)-$(date +%Y-%m-%d_%H-%M-%S)" \
  --exclude */tmp/* \
  --exclude *.core \
  $dirs > $logfile 2>&1

# Send email.
if [ $? -eq 0 ]; then
	subject="Tarsnap backup success"
else
	subject="Tarsnap backup FAILURE"
fi

#mail -s "$subject" $email_address < $logfile

