#!/bin/bash
#Just a simple script to wtite some stats to InfluxDB about your backup. Based on vzdump hook method.
TOKEN=<TOKEN>
ORGANIZATION=<ORGANIZATION>
LOCATIONCODE=<LOCATIONCODE>
PROTOCOL=<PROTOCOL> #HTTP or HTTPS
HOSTNAME=<HOSTNAME>
PORT=<PORT>
BUCKETNAME=<BUCKETNAME>
DEBUG=false #Debug mode, copy all logs to /tmp/timestamp
SPEED=""

if [ "$1" == "backup-start" ]; then
    echo `date +%s` > /tmp/backup-info
    echo $HOSTNAME >> /tmp/backup-info
fi

if [ "$1" == "log-end" ]; then
    if [ "$DEBUG" = true ]; then
        cp ${LOGFILE} /tmp/`date +%s`
    fi
    if [ `cat ${LOGFILE} | grep ERROR | wc -l` -gt 0 ]; then
        DURATION=$((`date +%s`-`sed '1q;d' /tmp/backup-info`))
        /usr/bin/curl --request POST "$PROTOCOL://$HOSTNAME:$PORT/api/v2/write?org=$ORGANIZATION&bucket=$BUCKETNAME&precision=ns" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=0,duration=$DURATION,speed=0,size=0" --header "Authorization: Token $TOKEN" --header "Content-Type: text/plain; charset=utf-8" --header "Accept: application/json"
        rm /tmp/backup-info
    else
        SPEED=`cat ${LOGFILE} | grep -o -P "(?<=seconds \().*(?= MB\/s| MiB\/s)"`
        if [ -z $SPEED ]; then
            SPEED=`cat ${LOGFILE} | grep -o -P "(?<=.iB, ).*(?=.iB\/s)"`
        fi
        DURATION=$((`cat ${LOGFILE} |grep -o -P "(?<=\()[0-9][0-9]:[0-9][0-9]:[0-9][0-9](?=\))"|awk -F':' '{print($1*3600)+($2*60)+$3}'`))
<<<<<<< HEAD
        TARFILE=`cat ${LOGFILE} | grep -o -P "creating vzdump archive '\K[^']+"`
        /usr/bin/curl --request POST "$PROTOCOL://$HOSTNAME:$PORT/api/v2/write?org=$ORGANIZATION&bucket=$BUCKETNAME&precision=ns" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=1,duration=$DURATION,speed=$SPEED,size=`stat -c%s $TARFILE`" --header "Authorization: Token $TOKEN" --header "Content-Type: text/plain; charset=utf-8" --header "Accept: application/json"
=======
        /usr/bin/curl -s -i -XPOST -u $DBUSER:$DBPASS "$DBPROTO://$DBHOST:$DBPORT/write?db=$DBNAME" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=1,duration=$DURATION,speed=$SPEED,size=`stat -c%s $TARGET`" > /tmp/tst
        echo $TARGET >> /tmp/tst
>>>>>>> 3f3d2ca38318b9a001f3b0821db1f6aafbfd7db6
    fi
fi
