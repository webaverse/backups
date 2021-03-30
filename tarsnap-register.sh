#!/bin/bash

# Exit if less than one parameter is provided.
[ "$#" -lt 1 ] && echo 'Error: Please provide a machine name.' && exit 1

EMAIL=services@webaverse.com
MACHINE=$1

sudo tarsnap-keygen \
  --keyfile /root/tarsnap.key \
  --user "$EMAIL" \
  --machine "$MACHINE"

echo "
Registered as $MACHINE. Please test the backup procedure and set a cron job.
"
