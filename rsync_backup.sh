#!/bin/bash

####################################################################################################
#                                           Config                                                 #
MAX_HOURS=5 # Set the maximum number of hours allowed since the last sync                          #
LOG_FILE="/var/log/rsync_backup.log" # Set the log file where sync times are recorded              #
SOURCE_SERVER="192.168.100.112" # Set the IP address or hostname of the source server              #
USERNAME="kali" # SSH User to access the dist                                                      #
LOCATION_SOURCE="/home/kali/test_sync/." # Source directory to sync from                             #
LOCATION_DIST="/tmp/test_sync/." # Destination directory to sync to                                  #
####################################################################################################


LOCKFILE="/root/rsync.lock"
FORCE_SYNC=false

while getopts ":f" opt; do
    case ${opt} in
        f )
            FORCE_SYNC=true
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            exit 1
            ;;
    esac
done

LAST_SYNC_TIME=$(grep "Rsync completed" $LOG_FILE | tail -1 | awk '{print $1,$2,$3,$4,$5}')

if [ "$FORCE_SYNC" = false ]; then
    if [ -z "$LAST_SYNC_TIME" ]; then
        echo "$(date) No previous sync found in the log. Proceeding with rsync." >> $LOG_FILE
    else
        LAST_SYNC_DATE=$(date -d "$LAST_SYNC_TIME" +%s 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "$(date) ERROR: Unable to parse last sync date: $LAST_SYNC_TIME" >> $LOG_FILE
            exit 1
        fi
        CURRENT_DATE=$(date +%s)
        TIME_DIFF=$((CURRENT_DATE - LAST_SYNC_DATE))
        MAX_HOURS_IN_SECONDS=$((MAX_HOURS * 3600))

        if [ $TIME_DIFF -gt $MAX_HOURS_IN_SECONDS ]; then
            echo "$(date) ################# ERROR: More than $MAX_HOURS hours since the last sync. Exiting rsync. ################# LAST Sync: $LAST_SYNC_TIME" >> $LOG_FILE
            exit 1
        fi
    fi
else
    echo "$(date) Warning: Force sync enabled. Skipping time check." >> $LOG_FILE
fi

if ! telnet $SOURCE_SERVER 22 </dev/null 2>&1 | grep -q "Connected"; then
    echo "$(date) !------- ERROR: Source server unreachable. Exiting rsync. -------!" >> $LOG_FILE
    exit 1
fi

if [ ! -f "$LOCKFILE" ]; then
    touch "$LOCKFILE"
fi

exec 500>$LOCKFILE
flock -n 500 || exit 1

echo "$(date) Starting rsync" >> $LOG_FILE
rsync -avz --delete $USERNAME@$SOURCE_SERVER:$LOCATION_SOURCE $LOCATION_DIST

if [ $? -eq 0 ]; then
    echo "$(date) Rsync completed" >> $LOG_FILE
else
    echo "$(date)  ERROR: Rsync failed" >> $LOG_FILE
fi

flock -u 500
