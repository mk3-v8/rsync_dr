#!/bin/bash

LOG_FILE="/var/log/rsync_backup.log"
MAX_HOURS=5
MAX_HOURS_IN_SECONDS=$((MAX_HOURS * 3600))
LAST_SYNC_TIME=$(grep "Rsync completed" $LOG_FILE | tail -1 | awk '{print $1,$2,$3,$4}')
CURRENT_DATE=$(date +%s)


if [ -z "$LAST_SYNC_TIME" ]; then
    echo "ALERT: No previous sync found in the log. Sync may not be working!"
    exit 1
fi

LAST_SYNC_DATE=$(date -d "$LAST_SYNC_TIME" +%s 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "ALERT: Unable to parse the last sync date. Sync may not be working!"
    exit 1
fi

TIME_DIFF=$((CURRENT_DATE - LAST_SYNC_DATE))

if [ $TIME_DIFF -gt $MAX_HOURS_IN_SECONDS ]; then
    echo "ALERT: More than $MAX_HOURS hours since the last successful sync! Sync was not working!"
    exit 1
fi

echo "Sync is working properly."