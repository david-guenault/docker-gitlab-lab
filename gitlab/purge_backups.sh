#!/usr/bin/env sh
. ./env.sh

backups=$(ls -1 $GITLAB_HOME/backups/*.tar)

for b in $backups; do 
    backup_archive=$b
    backup_ts=$(echo $b | awk -F/ '{print $NF}' | awk -F_ '{print $1}')
    max_days=$GITLAB_BACKUP_KEEP
    backup_max_date=$(date -d "$(date -d @$backup_ts) +$max_days days")
    backup_max_ts=$(date -d "$backup_max_date" +%s)
    backup_age_in_days=$(echo "$((($(date +%s) - $backup_ts)/86400))" )
    if [ $backup_age_in_days -ge $max_days ]; then
        echo "$backup_archive is $backup_age_in_days days old and will be removed."
        rm -f $backup_archive
    else
        echo "$backup_archive is $backup_age_in_days days old and will not be removed."
    fi
done

secret_backups=$(ls -1 $GITLAB_HOME/secret_backups/*.tar)

for b in $secret_backups; do 
    backup_archive=$b
    backup_ts=$(echo $b | awk -F/ '{print $NF}' | awk -F_ '{print $3}')
    max_days=$GITLAB_BACKUP_KEEP
    backup_max_date=$(date -d "$(date -d @$backup_ts) +$max_days days")
    backup_max_ts=$(date -d "$backup_max_date" +%s)
    backup_age_in_days=$(echo "$((($(date +%s) - $backup_ts)/86400))" )
    if [ $backup_age_in_days -ge $max_days ]; then
        echo "$backup_archive is $backup_age_in_days days old and will be removed."
        rm -f $backup_archive
    else
        echo "$backup_archive is $backup_age_in_days days old and will not be removed."
    fi
done

