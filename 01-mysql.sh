#!/bin/bash

LOG_FOLDER='/var/log/expense'
mkdir -p $LOG_FOLDER
sudo chown ec2-user:ec2-user -R $LOG_FOLDER
sudo chmod -R 755 $LOG_FOLDER

LOG_FILE="$LOG_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S" )

USER_ID=$( id -u )

if [ "$USER_ID" -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR]  Please login with sudo access ... $R FAILURE $N"
    exit 1
fi



