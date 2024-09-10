#!/bin/bash


####################################################################################################
#                                           Config                                                 #
MAX_HOURS=5 # Set the maximum number of hours allowed since the last sync                          #
LOG_FILE="/var/log/rsync_backup.log" # Set the log file where sync times are recorded              #
DR_SERVER="192.168.1.10" # Set the IP address or hostname of the DR server                         #
LOCATION_SOURCE="/mnt"                                                                             #
LOCATION_DIST="/mnt"                                                                               #
####################################################################################################



LOCKFILE="/root/rsync.lock"
LAST_SYNC_TIME=$(grep "Rsync completed" $LOG_FILE | tail -1 | awk '{print $1,$2,$3,$4,$5}')

# Check if we have a valid last sync time
if [ -z "$LAST_SYNC_TIME" ]; then
    echo "$(date): No previous sync found in the log. Proceeding with rsync." >> /var/log/rsync_backup.log
else
    LAST_SYNC_DATE=$(date -d "$LAST_SYNC_TIME" +%s)
    CURRENT_DATE=$(date +%s)
    TIME_DIFF=$((CURRENT_DATE - LAST_SYNC_DATE))
    MAX_HOURS_IN_SECONDS=$((MAX_HOURS * 3600))
    if [ $TIME_DIFF -gt $MAX_HOURS_IN_SECONDS ]; then
        echo "$(date): ################# ERROR: More than $MAX_HOURS hours since the last sync. Exiting rsync. #################" >> /var/log/rsync_backup.log
        exit 1
    fi
fi

# Check if the DR server is reachable on port 22 using telnet
if ! telnet $DR_SERVER 22 </dev/null 2>&1 | grep -q "Connected"; then
    echo "$(date): !------- ERROR: DR server unreachable. Exiting rsync. -------!" >> /var/log/rsync_backup.log
    exit 1
fi

# Check if the lock file exists, if not create it
if [ ! -f "$LOCKFILE" ]; then
    touch "$LOCKFILE"
fi


exec 500>$LOCKFILE
flock -n 500 || exit 1
echo "$(date): Starting rsync" >> /var/log/rsync_backup.log
rsync -avz --delete $LOCATION_SOURCE user@$DR_SERVER:$LOCATION_DIST
echo "$(date): Rsync completed" >> /var/log/rsync_backup.log
flock -u 500