```
cp rsync_backup.sh /usr/local/bin/
chmod +x /usr/local/bin/rsync_backup.sh


# Define the cron job to add (in this example, it's set to run a backup script every day at 2 AM)
CRON_JOB="* * * * * /usr/local/bin/rsync_backup.sh"
crontab -l | grep -q "$CRON_JOB"
if [ $? -eq 0 ]; then
    echo "Cron job already exists. No changes made."
else
    # Append the new cron job to the crontab
    (crontab -l; echo "$CRON_JOB") | crontab -
    echo "New cron job added: $CRON_JOB"
fi







cp check_sync.sh /usr/local/bin/
chmod +x /usr/local/bin/check_sync.sh
echo "/usr/local/bin/check_sync.sh" >> /root/.bashrc
```
