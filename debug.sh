#!/bin/bash

####################################################################################################
#                                           Config                                                 #
MAX_HOURS=5 # Set the maximum number of hours allowed since the last sync                          #
LOG_FILE="/var/log/rsync_backup.log" # Set the log file where sync times are recorded              #
DR_SERVER="192.168.1.10" # Set the IP address or hostname of the DR server                         #
LOCATION_SOURCE="/mnt"
LOCATION_DIST="/mnt"
####################################################################################################


LOCKFILE="/root/rsync.lock"
LAST_SYNC_TIME=$(grep "Rsync completed" $LOG_FILE | tail -1 | awk '{print $1,$2,$3,$4,$5}')

# Check if we have a valid last sync time
if [ -z "$LAST_SYNC_TIME" ]; then
    echo "$(date): No previous sync found in the log. Proceeding with rsync."
else
    echo "$(date): Last sync time found in the log: $LAST_SYNC_TIME"
    
    LAST_SYNC_DATE=$(date -d "$LAST_SYNC_TIME" +%s)
    CURRENT_DATE=$(date +%s)
    TIME_DIFF=$((CURRENT_DATE - LAST_SYNC_DATE))
    MAX_HOURS_IN_SECONDS=$((MAX_HOURS * 3600))

    echo "$(date): Last sync date (in seconds since epoch): $LAST_SYNC_DATE"
    echo "$(date): Current date (in seconds since epoch): $CURRENT_DATE"
    echo "$(date): Time difference (in seconds): $TIME_DIFF"
    echo "$(date): Maximum allowed time difference (in seconds): $MAX_HOURS_IN_SECONDS"
    
    if [ $TIME_DIFF -gt $MAX_HOURS_IN_SECONDS ]; then
        echo "$(date): ################# ERROR: More than $MAX_HOURS hours since the last sync. Exiting rsync. #################"
        exit 1 # Commented for debugging
    else
        echo "$(date): Last sync was within the allowed time frame."
    fi
fi

# Simulate checking the server connection
echo "$(date): Checking connection to DR server $DR_SERVER on port 22 (simulated)..."
# if ! telnet $DR_SERVER 22 </dev/null 2>&1 | grep -q "Connected"; then
if ! telnet $DR_SERVER 22 </dev/null 2>&1 | grep -q "Connected"; then
    echo "$(date): !------- ERROR: DR server unreachable. Exiting rsync. -------!"
    exit 1 # Commented for debugging
else
    echo "$(date): DR server is reachable."
fi

# Check if the lock file exists, if not create it (simulated)
if [ ! -f "$LOCKFILE" ]; then
    echo "$(date): Lock file not found. Creating lock file (simulated)..."
    touch "$LOCKFILE" # Commented for debugging
else
    echo "$(date): Lock file exists."
fi

# Simulate locking mechanism
exec 500>$LOCKFILE
echo "$(date): Attempting to acquire lock (simulated)..."
# flock -n 500 || exit 1 # Commented for debugging

# Simulate rsync
echo "$(date): Starting rsync (simulated)..."
# rsync -avz --delete $LOCATION_SOURCE user@$DR_SERVER:$LOCATION_DIST # Commented for debugging
echo "$(date): Rsync completed (simulated)."

# Simulate releasing the lock
# flock -u 500 # Commented for debugging
echo "$(date): Lock released (simulated)."
