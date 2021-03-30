#!/bin/bash

# This script installs tarsnap and it's required dependencies.
# It also ensures the packaging keys match.

# Install dependencies.
# lsb-release is needed for adding the correct tarsnap package repository.
# perl is needed to fuzz the cron job times.
sudo apt --fix-broken install -y
sudo apt install -y lsb-release perl

# Get Tarsnap packaging key.
PACKAGING_KEY=tarsnap-deb-packaging-key.asc
wget "https://pkg.tarsnap.com/$PACKAGING_KEY"

# Verify key.
KEYIDS_MATCH=false

# Get keyids.
# See: https://www.tarsnap.com/pkg-deb.html#initial-setup
KNOWN_KEYIDS='BF75EEAB040E447C
38CECA690C6A6A6E'

KEYIDS=$( gpg --list-packets "$PACKAGING_KEY" | grep signature | awk '{print $6}' )

[ "$KEYIDS" = "$KNOWN_KEYIDS" ] && KEYIDS_MATCH=true

[ ! $KEYIDS_MATCH = true ] && 
echo "FATAL: Package signing keys do not match.\n" &&
echo "Expected:\n$KNOWN_KEYIDS\n" &&
echo "Received:\n$KEYIDS\n" &&
exit 1

## Add key to system.
sudo apt-key add "$PACKAGING_KEY"
rm "./$PACKAGING_KEY"

# Add Tarsnap binary package repository to system.
printf "deb http://pkg.tarsnap.com/deb/$(lsb_release -s -c) ./\n" | sudo tee /etc/apt/sources.list.d/tarsnap.list

# Update package database
sudo apt update

# Install Tarsnap
sudo apt install -y tarsnap

# Finished!
printf "
Tarsnap is installed.
Please register the machine with tarsnap-register.sh using a unique ID.

"
