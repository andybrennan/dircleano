#!/bin/bash
# Andy B June 2018
# Clear up files captured by kerberosio
# v0.1  Initial version
# v0.2  Changed logging when finding zero files older than X days 
#       and skip out of loop iteration.
# v0.2a Corrected error in loop where processing stops if no files
#       older than $DAYS have been found
# v0.3  Renamed to dircleano. Moved config params to dircleano.conf


if [ -e dircleano.conf ]; then
    . dircleano.conf
else
    DIR="/etc/opt/kerberosio/capture"
    USAGE=85 # disk utilisation
    DAYS=4 # delete files older than this
    LOG="/var/log/tidyup.log"
fi

# Sanity check before moving on...

if [ -z $DIR ]; then
    echo `date +'%b %d %X'` "ERROR: variables not set!" >> $LOG
fi

current_usage=`df -h / | grep root | awk '{print $5+0}'`
echo `date +'%b %d %X'` "Current disk utilisation: $current_usage" >> $LOG

while [[ $current_usage -ge $USAGE ]] && [[ $DAYS -ge 0 ]]; do
    oldfiles=`find $DIR -type f -mtime +$DAYS -exec ls {} \; | wc -l`
    if [[ $oldfiles -eq 0 ]]; then #added this in v0.1a
        echo "`date +'%b %d %X'` Found no files older than $DAYS day(s)" >> $LOG
        DAYS=$((DAYS-1))
        continue 
    else
        echo "`date +'%b %d %X'` Found $oldfiles files older than $DAYS day(s), deleting them" >> $LOG
    fi
    find $DIR -type f -mtime +$DAYS -exec rm {} \;
    
    current_usage=`df -h / | grep root | awk '{print $5+0}'`
    echo `date +'%b %d %X'` "Current disk utilisation: $current_usage" >> $LOG
    DAYS=$((DAYS-1))
done
